# Cloud Support and Engineering — Terraform Infrastructure

This repository contains reusable Terraform infrastructure for provisioning a complete Kubernetes-based application environment on **AWS** and **Azure**, with separate folders for each cloud and separate configurations for `dev`, `staging`, and `prod` environments.

## Architecture

```
                         Internet
                            |
                       DNS Hostname
                            |
                     Public Load Balancer
                            |
                       Traefik Ingress
                            |
                      Kubernetes Service
                            |
                     Application Pods
                            |
                   Managed PostgreSQL
```

Both clouds implement the same architecture using their native managed services:

| Requirement        | Azure                              | AWS                        |
|--------------------|------------------------------------|----------------------------|
| Kubernetes         | AKS                                | EKS                        |
| PostgreSQL         | Azure Database for PostgreSQL (Flexible) | Amazon RDS for PostgreSQL |
| Load Balancer      | Azure Standard Load Balancer        | AWS NLB                    |
| DNS                | Azure DNS                          | Route 53                   |
| Ingress            | Traefik (Helm)                     | Traefik (Helm)             |
| Secrets            | Azure Key Vault                    | AWS Secrets Manager        |
| Networking         | VNet + NSGs                        | VPC + Security Groups      |

## Project Structure

```
terraform/
├── aws/
│   ├── modules/
│   │   ├── networking/      # VPC, subnets, NAT gateway, route tables
│   │   ├── kubernetes/      # EKS cluster, node group, IAM roles
│   │   ├── postgres/        # RDS PostgreSQL, Secrets Manager
│   │   ├── traefik/          # Traefik Helm release, LoadBalancer service
│   │   ├── dns/             # Route 53 hosted zone and record
│   │   └── app/             # Sample app deployment, service, ingress
│   └── environments/
│       ├── dev/             # Dev environment config
│       ├── staging/         # Staging environment config
│       └── prod/            # Prod environment config
│
├── azure/
│   ├── modules/
│   │   ├── networking/      # VNet, subnets, NSGs, Private DNS Zone
│   │   ├── kubernetes/      # AKS cluster, Managed Identity
│   │   ├── postgres/        # PostgreSQL Flexible Server, private access
│   │   ├── traefik/          # Traefik Helm release, LoadBalancer service
│   │   ├── dns/             # Azure DNS zone and A record
│   │   └── app/             # Sample app deployment, service, ingress
│   └── environments/
│       ├── dev/             # Dev environment config
│       ├── staging/         # Staging environment config
│       └── prod/            # Prod environment config
│
├── README.md
└── .gitignore
```

## Prerequisites

### AWS
- AWS CLI configured with credentials (`aws configure`)
- Terraform >= 1.5.0
- `kubectl` and `helm` installed locally
- An S3 bucket for Terraform state (optional but recommended)

### Azure
- Azure CLI logged in (`az login`)
- Terraform >= 1.5.0
- `kubectl` and `helm` installed locally
- An Azure Storage account for Terraform state (optional but recommended)
- Sufficient subscription permissions to create resource groups, AKS, PostgreSQL, Key Vault, DNS zones

## Usage

### 1. Choose your cloud and environment

```bash
# AWS dev
cd terraform/aws/environments/dev

# Azure staging
cd terraform/azure/environments/staging
```

### 2. Copy the example tfvars and customize

```bash
cp terraform.tfvars.example terraform.tfvars
```

**IMPORTANT**: Edit `terraform.tfvars` and change all values marked with `CHANGE THIS`:
- VPC/VNet names
- Cluster names
- PostgreSQL server names
- Domain names (you must own the domain)
- Key Vault name (Azure — must be globally unique)
- Resource group names

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Review the plan

```bash
terraform plan
```

### 5. Apply

```bash
terraform apply
```

### 6. Get outputs

```bash
terraform output
```

Key outputs include:
- `application_hostname` — the DNS hostname for accessing the app
- `application_url` — full HTTPS URL
- `kubernetes_cluster_name` — name of the cluster
- `postgres_endpoint` — database endpoint/FQDN
- `traefik_public_ip` / `traefik_public_hostname` — LoadBalancer endpoint

### 7. Connect kubectl to the cluster

**AWS:**
```bash
aws eks update-kubeconfig --name <cluster-name> --region <region>
```

**Azure:**
```bash
az aks get-credentials --resource-group <rg-name> --name <cluster-name>
```

### 8. Verify the application

```bash
curl https://<application_hostname>/
# Expected: Hello from <Azure/AWS> Kubernetes

curl https://<application_hostname>/health
# Expected: {"application":"healthy","database":"connected"}
```

### 9. Tear down

```bash
terraform destroy
```

## What You Need to Change

Every variable marked with `CHANGE THIS` in the `.tf` files and `terraform.tfvars.example` files must be reviewed:

| Variable              | Where                  | Why                                          |
|-----------------------|------------------------|----------------------------------------------|
| `vpc_name`/`vnet_name`| variables.tf           | Must be unique within your account/subscription |
| `cluster_name`        | variables.tf           | Must be unique within your account/subscription |
| `postgres_name`       | variables.tf           | Must be unique; used for DB instance and secret |
| `domain_name`         | variables.tf / tfvars  | You must own this domain                      |
| `dns_zone_name`       | variables.tf / tfvars  | Azure: must match your registered domain      |
| `dns_record_name`     | variables.tf / tfvars  | Subdomain prefix (dev, staging, prod)        |
| `key_vault_name`      | variables.tf / tfvars  | Azure: must be globally unique (3-24 chars)   |
| `resource_group_name` | variables.tf / tfvars  | Azure: must be unique within subscription     |
| Backend config        | versions.tf            | Uncomment and set your state bucket/account   |

## Security

- Database passwords are auto-generated using `random_password` and stored in:
  - **AWS**: AWS Secrets Manager
  - **Azure**: Azure Key Vault
- No credentials are committed to source control
- PostgreSQL has public network access disabled (Azure) or is in private subnets (AWS)
- All sensitive outputs are marked as `sensitive = true`
- `.gitignore` excludes `terraform.tfvars`, `.terraform/`, and state files

## Environments

| Environment | AWS VPC CIDR | Azure VNet CIDR | Purpose                    |
|-------------|-------------|-----------------|----------------------------|
| dev         | 10.0.0.0/16 | 10.0.0.0/16     | Development and learning   |
| staging     | 10.1.0.0/16 | 10.1.0.0/16     | Pre-production testing      |
| prod        | 10.2.0.0/16 | 10.2.0.0/16     | Production                 |

Each environment uses different CIDR ranges so they can coexist in the same account/subscription without conflicts.

## Providers Used (Official Terraform Registry)

| Provider      | Source                  | Version  |
|---------------|-------------------------|----------|
| aws           | hashicorp/aws           | ~> 5.0   |
| azurerm       | hashicorp/azurerm       | ~> 3.100 |
| kubernetes    | hashicorp/kubernetes    | ~> 2.23  |
| helm          | hashicorp/helm          | ~> 2.11  |
| kubectl       | gavinbunney/kubectl     | ~> 1.14  |
| random        | hashicorp/random        | ~> 3.5   |
