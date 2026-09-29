#!/usr/bin/env bash

set -euo pipefail

REGION="us-east-1"
CLUSTER_NAME="dev-cluster"
NAMESPACE="petclinic"

ACCOUNT_ID="$(aws sts get-caller-identity \
  --query Account \
  --output text)"

ECR_REPOSITORY="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/petclinic"

IMAGE_TAG="$(git rev-parse --short HEAD)"

echo "======================================"
echo "Deploying Spring Petclinic"
echo "======================================"

echo "→ ECR login"

aws ecr get-login-password \
  --region "$REGION" |
  docker login \
  --username AWS \
  --password-stdin "$ECR_REPOSITORY"

echo "→ Building Docker image"

docker build \
  -t "${ECR_REPOSITORY}:${IMAGE_TAG}" \
  .

echo "→ Pushing Docker image"

docker push "${ECR_REPOSITORY}:${IMAGE_TAG}"

echo "→ Configuring EKS"

aws eks update-kubeconfig \
  --region "$REGION" \
  --name "$CLUSTER_NAME"

echo "→ Deploying with Helm"

helm upgrade --install petclinic \
  ./petclinic-helm-chart \
  --namespace "$NAMESPACE" \
  --create-namespace \
  --set image.repository="$ECR_REPOSITORY" \
  --set image.tag="$IMAGE_TAG" \
  --wait \
  --timeout 10m

echo ""
echo "======================================"
echo "Deployment complete"
echo "======================================"

kubectl get pods -n "$NAMESPACE"

echo ""
echo "Application:"
echo "http://$(kubectl get ingress petclinic \
  -n "$NAMESPACE" \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"