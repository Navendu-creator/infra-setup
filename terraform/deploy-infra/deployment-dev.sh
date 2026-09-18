#!/usr/bin/env bash
#
# deployment-dev.sh
#
# Creates or destroys the DEV environment infrastructure.
#
# Usage:
#   ./deployment-dev.sh validate
#   ./deployment-dev.sh plan
#   ./deployment-dev.sh create
#   ./deployment-dev.sh delete
#   ./deployment-dev.sh create --auto-approve   # non-interactive (used in CI)
#
set -euo pipefail

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------
ENVIRONMENT="dev"
CLUSTER_NAME="${ENVIRONMENT}-cluster"
AWS_REGION="${AWS_REGION:-us-east-1}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_DIR="$(cd "${SCRIPT_DIR}/../aws/environments/${ENVIRONMENT}" && pwd)"

VALID_ACTIONS=("create" "delete" "plan" "validate")

ACTION="${1:-}"
FLAG="${2:-}"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
log()  { echo -e "\033[1;34m[deploy:${ENVIRONMENT}]\033[0m $*"; }
warn() { echo -e "\033[1;33m[deploy:${ENVIRONMENT}]\033[0m $*"; }
err()  { echo -e "\033[1;31m[deploy:${ENVIRONMENT}]\033[0m $*" >&2; }

usage() {
  cat <<EOF
Usage: $(basename "$0") <action> [--auto-approve]

  action           validate | plan | create | delete
  --auto-approve   skip interactive confirmation (used in CI)

Examples:
  $(basename "$0") validate
  $(basename "$0") plan
  $(basename "$0") create
  $(basename "$0") delete --auto-approve
EOF
  exit 1
}

# ---------------------------------------------------------------------------
# Validate arguments
# ---------------------------------------------------------------------------
if [[ -z "$ACTION" ]]; then
  err "Missing required action argument."
  usage
fi

VALID=false
for a in "${VALID_ACTIONS[@]}"; do
  [[ "$a" == "$ACTION" ]] && VALID=true
done
if [[ "$VALID" == false ]]; then
  err "Invalid action: '$ACTION'. Must be one of: ${VALID_ACTIONS[*]}"
  usage
fi

AUTO_APPROVE=false
if [[ "$FLAG" == "--auto-approve" ]]; then
  AUTO_APPROVE=true
fi

if [[ ! -d "$ENV_DIR" ]]; then
  err "Environment directory not found: $ENV_DIR"
  exit 1
fi

log "Environment : $ENVIRONMENT"
log "Action      : $ACTION"
log "Working dir : $ENV_DIR"

# ---------------------------------------------------------------------------
# Pre-destroy cleanup: remove the Kubernetes-managed LoadBalancer before
# touching the VPC/cluster, so subnet/IGW deletion never gets stuck on an
# orphaned NLB. Safe to no-op if the cluster doesn't exist yet.
# ---------------------------------------------------------------------------
pre_destroy_cleanup() {
  log "Attempting pre-destroy cleanup of Kubernetes-managed LoadBalancer..."

  if aws eks describe-cluster --name "$CLUSTER_NAME" --region "$AWS_REGION" >/dev/null 2>&1; then
    aws eks update-kubeconfig --region "$AWS_REGION" --name "$CLUSTER_NAME" || true

    log "Deleting traefik LoadBalancer service (if present)..."
    kubectl delete svc traefik -n traefik --ignore-not-found=true --timeout=120s || true

    log "Waiting 90s for AWS to deprovision the NLB..."
    sleep 90
  else
    log "Cluster '$CLUSTER_NAME' not found — skipping LB cleanup."
  fi
}

# ---------------------------------------------------------------------------
# Self-heal: detect known drift between AWS reality and Terraform state,
# and auto-import instead of requiring manual intervention. Safe to run
# every time — all checks are no-ops if nothing has drifted.
# ---------------------------------------------------------------------------
self_heal_state() {
  log "Checking for state drift on known resources..."

  local secret_name="${ENVIRONMENT}-postgres-credentials"
  local secret_address="module.postgres.aws_secretsmanager_secret.db_credentials"

  if aws secretsmanager describe-secret --secret-id "$secret_name" >/dev/null 2>&1; then
    if ! terraform state list 2>/dev/null | grep -qx "$secret_address"; then
      log "Secret '$secret_name' exists in AWS but is not in Terraform state."

      local deleted_date
      deleted_date=$(aws secretsmanager describe-secret --secret-id "$secret_name" --query 'DeletedDate' --output text 2>/dev/null || echo "None")
      if [[ "$deleted_date" != "None" ]]; then
        log "Secret is pending deletion — restoring it..."
        aws secretsmanager restore-secret --secret-id "$secret_name" || true
      fi

      log "Importing secret into Terraform state..."
      terraform import "$secret_address" "$secret_name" || warn "Secret import failed — will surface as a normal terraform error if still unresolved."
    fi
  fi

  local principal_arn
  principal_arn=$(aws sts get-caller-identity --query Arn --output text 2>/dev/null || echo "")
  local access_entry_address="module.kubernetes.aws_eks_access_entry.this"

  if [[ -n "$principal_arn" ]] && aws eks describe-cluster --name "$CLUSTER_NAME" --region "$AWS_REGION" >/dev/null 2>&1; then
    if aws eks list-access-entries --cluster-name "$CLUSTER_NAME" --region "$AWS_REGION" --query "accessEntries" --output text 2>/dev/null | grep -q "$principal_arn"; then
      if ! terraform state list 2>/dev/null | grep -qx "$access_entry_address"; then
        log "Access entry for '$principal_arn' exists in AWS but is not in Terraform state."
        log "Importing access entry into Terraform state..."
        terraform import "$access_entry_address" "${CLUSTER_NAME}:${principal_arn}" || warn "Access entry import failed — will surface as a normal terraform error if still unresolved."
      fi
    fi
  fi

  log "State drift check complete."
}

# ---------------------------------------------------------------------------
# Actions
# ---------------------------------------------------------------------------
cd "$ENV_DIR"

case "$ACTION" in

  validate)
    log "Running terraform init..."
    terraform init -input=false -reconfigure

    log "Checking formatting (terraform fmt -check)..."
    if ! terraform fmt -check -recursive; then
      warn "Formatting issues found. Run 'terraform fmt -recursive' to fix."
    fi

    log "Running terraform validate..."
    terraform validate

    log "Validate completed successfully."
    ;;

  plan)
    log "Running terraform init..."
    terraform init -input=false -reconfigure

    self_heal_state

    log "Running terraform plan..."
    terraform plan -input=false -out=tfplan
    ;;

  create)
    log "Running terraform init..."
    terraform init -input=false -reconfigure

    self_heal_state

    log "Running terraform plan..."
    terraform plan -input=false -out=tfplan

    log "Running terraform apply..."
    if [[ "$AUTO_APPROVE" == true ]]; then
      terraform apply -input=false -auto-approve tfplan
    else
      terraform apply -input=false tfplan
    fi

    log "Refreshing kubeconfig..."
    aws eks update-kubeconfig --region "$AWS_REGION" --name "$CLUSTER_NAME" || true

    log "Create completed successfully."
    ;;

  delete)
    log "Running terraform init..."
    terraform init -input=false -reconfigure

    pre_destroy_cleanup

    log "Running terraform destroy..."
    if [[ "$AUTO_APPROVE" == true ]]; then
      terraform destroy -input=false -auto-approve
    else
      terraform destroy -input=false
    fi

    log "Delete completed successfully."
    ;;

  *)
    err "Unhandled action: $ACTION"
    exit 1
    ;;
esac