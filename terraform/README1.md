# AWS EKS DevOps Architecture

This repository contains a Terraform-managed AWS infrastructure with Amazon EKS, Amazon RDS PostgreSQL, Traefik as the ingress/load-balancing layer, Argo CD for GitOps deployment, and Spring Petclinic as the application workload.

## Architecture

```text
                                Internet
                                   |
                                   v
                    +--------------------------------+
                    |        AWS Network Load        |
                    |          Balancer (NLB)        |
                    |                                |
                    |  :80    :8080       :443       |
                    +----+-------+----------+---------+
                         |       |          |
                         |       |          |
                         v       v          v
                    +--------------------------------+
                    |            Traefik             |
                    |        Kubernetes Ingress       |
                    |          Controller             |
                    +-------------+------------------+
                                  |
                    +-------------+-------------+
                    |                           |
                 :80 / web                 :8080 / petclinic
                    |                           |
                    v                           v
             +-------------+             +-------------+
             |   Argo CD   |             |  Petclinic  |
             |   Ingress   |             |   Ingress   |
             +------+------+             +------+------+
                    |                           |
                    v                           v
             +-------------+             +-------------+
             | argocd-     |             | petclinic   |
             | server      |             | Service     |
             | ClusterIP   |             | ClusterIP   |
             +-------------+             +------+------+
                                                |
                                                v
                                         +-------------+
                                         | Spring      |
                                         | Petclinic   |
                                         | Pod         |
                                         +------+------+
                                                |
                                                v
                                         +-------------+
                                         | Amazon RDS  |
                                         | PostgreSQL  |
                                         +-------------+

                         Amazon EKS Cluster
```

### Request flow

**Argo CD**

```text
Client
  |
  v
NLB :80
  |
  v
Traefik web entrypoint
  |
  v
Argo CD Ingress
  |
  v
argocd-server:80
```

**Spring Petclinic**

```text
Client
  |
  v
NLB :8080
  |
  v
Traefik petclinic entrypoint
  |
  v
Petclinic Ingress
  |
  v
petclinic Service :8080
  |
  v
Petclinic Pod
  |
  v
Amazon RDS PostgreSQL
```

The Petclinic Ingress is intentionally hostless. Port-based routing is used so that Argo CD and Petclinic can share the same NLB DNS name without requiring separate domains.

---

## Repository Structure

```text
infra-setup/
├── terraform/
│   └── aws/
│       ├── environments/
│       │   └── dev/
│       └── modules/
│           ├── networking/
│           ├── kubernetes/
│           ├── postgres/
│           ├── traefik/
│           └── dns/
│
├── argocd-server/
│   ├── values.yaml
│   └── ...
│
└── spring-petclinic/
    ├── petclinic-helm-chart/
    │   ├── Chart.yaml
    │   ├── values.yaml
    │   └── templates/
    └── ...
```

## Infrastructure Components

| Component | Purpose |
|---|---|
| AWS VPC | Network isolation and subnet architecture |
| Amazon EKS | Kubernetes platform |
| Amazon RDS PostgreSQL | Managed application database |
| Traefik | Kubernetes ingress controller |
| AWS NLB | Public entry point for HTTP traffic |
| Argo CD | GitOps continuous delivery |
| Helm | Application packaging |
| Spring Petclinic | Sample application |
| Terraform | Infrastructure provisioning |

## Current Environment

| Parameter | Value |
|---|---|
| Cloud | AWS |
| Region | `us-east-1` |
| EKS Cluster | `dev-cluster` |
| Resource Prefix | `dev-vpc` |
| Database | `appdb` |
| Database Engine | PostgreSQL |
| NLB DNS | `aa5a471ab34464e5c9e93bab89ca4323-dbcf03ce92547897.elb.us-east-1.amazonaws.com` |

> **Security:** Database credentials and sensitive ARNs are intentionally not stored in this README.

## Application URLs

### Argo CD

The intended Argo CD URL is:

```text
http://aa5a471ab34464e5c9e93bab89ca4323-dbcf03ce92547897.elb.us-east-1.amazonaws.com/
```

Argo CD is exposed through Traefik on port `80`.

If Traefik is configured with an HTTP-to-HTTPS redirect, HTTP requests on port `80` will be redirected to HTTPS.

### Spring Petclinic

The intended Petclinic URL is:

```text
http://aa5a471ab34464e5c9e93bab89ca4323-dbcf03ce92547897.elb.us-east-1.amazonaws.com:8080/
```

Petclinic is exposed through the dedicated Traefik `petclinic` entrypoint on port `8080`.

---

# Setup

## Prerequisites

Install/configure:

- AWS CLI
- Terraform
- kubectl
- Helm
- Git
- AWS credentials with permission to create the required infrastructure

Verify:

```bash
aws sts get-caller-identity
terraform version
kubectl version --client
helm version
git --version
```

---

## 1. Provision AWS Infrastructure

Go to the development Terraform environment:

```bash
cd terraform/aws/environments/dev
```

Initialize Terraform:

```bash
terraform init
```

Review the plan:

```bash
terraform plan
```

Apply:

```bash
terraform apply
```

After Terraform completes, verify the outputs:

```bash
terraform output
```

Expected important outputs include:

```text
cloud = "AWS"
region = "us-east-1"
cluster_name = "dev-cluster"
kubernetes_cluster_name = "dev-cluster"
postgres_database_name = "appdb"
postgres_endpoint = "dev-postgres.cu9m0gmg871y.us-east-1.rds.amazonaws.com"
traefik_public_hostname = "aa5a471ab34464e5c9e93bab89ca4323-dbcf03ce92547897.elb.us-east-1.amazonaws.com"
```

Do **not** commit Terraform state files, `.terraform/`, or sensitive outputs.

---

## 2. Configure kubectl

Update the local kubeconfig:

```bash
aws eks update-kubeconfig \
  --region us-east-1 \
  --name dev-cluster
```

Verify:

```bash
kubectl config current-context
kubectl get nodes
```

Expected cluster:

```text
dev-cluster
```

---

## 3. Verify Traefik

Check the Traefik service:

```bash
kubectl get svc -n traefik
```

Expected ports:

```text
8080:30793/TCP,80:30894/TCP,443:30372/TCP
```

The important external ports are:

```text
80    -> Traefik web
8080  -> Traefik petclinic
443   -> Traefik websecure
```

The AWS NLB DNS should be:

```text
aa5a471ab34464e5c9e93bab89ca4323-dbcf03ce92547897.elb.us-east-1.amazonaws.com
```

---

# 4. Deploy Argo CD

Argo CD is deployed into the `argocd` namespace.

Verify the namespace:

```bash
kubectl get ns argocd
```

Verify the Argo CD workloads:

```bash
kubectl get pods -n argocd
```

All Argo CD components should eventually show `Running`/`Ready`.

Verify the services:

```bash
kubectl get svc -n argocd
```

The Argo CD server remains a `ClusterIP` service. External access is provided by the Traefik Ingress and AWS NLB.

Verify the Ingress:

```bash
kubectl get ingress -n argocd
```

The Argo CD Ingress uses:

```yaml
ingressClassName: traefik
```

and the Traefik `web` entrypoint.

---

# 5. Access Argo CD

Get the NLB hostname:

```bash
kubectl get svc traefik -n traefik
```

Open:

```text
http://<NLB-DNS>/
```

For the current environment:

```text
http://aa5a471ab34464e5c9e93bab89ca4323-dbcf03ce92547897.elb.us-east-1.amazonaws.com/
```

If HTTP-to-HTTPS redirection is enabled on Traefik, access will be redirected to HTTPS.

---

# 6. Configure Argo CD for Petclinic

The application deployment is handled by Argo CD rather than manually running Helm commands.

The Petclinic Helm chart is located at:

```text
spring-petclinic/petclinic-helm-chart
```

The chart should configure the Petclinic Ingress to use the Traefik `petclinic` entrypoint:

```yaml
ingress:
  enabled: true
  host: ""
  className: traefik
  entrypoint: petclinic
  tls: false
```

The generated Ingress should contain:

```yaml
annotations:
  traefik.ingress.kubernetes.io/router.entrypoints: petclinic
```

This is important because the application is exposed through port `8080`, not the normal Traefik `web` entrypoint.

---

# 7. Deploy Petclinic Through Argo CD

Once the Argo CD Application is configured against the Git repository containing the Petclinic Helm chart:

```text
Git Repository
      |
      v
    Argo CD
      |
      v
Helm Chart
      |
      v
Kubernetes
      |
      v
Petclinic Deployment
      |
      v
Petclinic Service
      |
      v
Petclinic Ingress
      |
      v
Traefik :8080
```

Check the deployed resources:

```bash
kubectl get all -n petclinic
```

Expected:

```text
Deployment: petclinic
Pod:        petclinic-xxxxx
Service:    petclinic
Port:       8080
```

Check the Ingress:

```bash
kubectl get ingress -n petclinic
```

Verify that it uses the correct entrypoint:

```bash
kubectl get ingress petclinic -n petclinic \
  -o jsonpath='{.metadata.annotations.traefik\.ingress\.kubernetes\.io/router\.entrypoints}{"\n"}'
```

Expected:

```text
petclinic
```

---

# 8. Verify Petclinic

Test the NLB directly:

```bash
curl -I http://aa5a471ab34464e5c9e93bab89ca4323-dbcf03ce92547897.elb.us-east-1.amazonaws.com:8080/
```

Open in a browser:

```text
http://aa5a471ab34464e5c9e93bab89ca4323-dbcf03ce92547897.elb.us-east-1.amazonaws.com:8080/
```

---

# 9. Database

Petclinic uses Amazon RDS PostgreSQL.

Current database:

```text
Database: appdb
Endpoint: dev-postgres.cu9m0gmg871y.us-east-1.rds.amazonaws.com
Port: 5432
```

The application should consume database credentials from a Kubernetes Secret generated/managed as part of the deployment configuration.

Never commit:

- Database passwords
- AWS access keys
- Secret values
- Terraform state
- Private keys
- Sensitive ARNs if they are not intended for source control

---

# Verification Commands

## EKS

```bash
kubectl get nodes -o wide
```

## Traefik

```bash
kubectl get pods -n traefik
kubectl get svc -n traefik
```

## Argo CD

```bash
kubectl get pods -n argocd
kubectl get svc -n argocd
kubectl get ingress -n argocd
```

## Petclinic

```bash
kubectl get pods -n petclinic
kubectl get svc -n petclinic
kubectl get ingress -n petclinic
```

## All namespaces

```bash
kubectl get pods -A
```

---

# Troubleshooting

## Traefik returns 404 on port 8080

Check the Petclinic Ingress entrypoint:

```bash
kubectl get ingress petclinic -n petclinic \
  -o jsonpath='{.metadata.annotations.traefik\.ingress\.kubernetes\.io/router\.entrypoints}{"\n"}'
```

It must return:

```text
petclinic
```

Check the Traefik service:

```bash
kubectl get svc traefik -n traefik
```

Port `8080` must be exposed.

Check the Petclinic service:

```bash
kubectl get svc petclinic -n petclinic
kubectl get endpoints petclinic -n petclinic
```

The Petclinic service should have healthy endpoints.

---

## HTTP redirects to HTTPS

Check the Traefik Helm configuration.

If the following is configured:

```yaml
web:
  redirectTo:
    port: websecure
```

Traefik will redirect HTTP requests received on port `80` to HTTPS.

Remove/disable this setting if plain HTTP on port `80` is required.

---

## Argo CD pods are running but UI is unavailable

Check:

```bash
kubectl get ingress -n argocd
kubectl describe ingress argocd-server -n argocd
kubectl logs -n traefik deploy/traefik
```

Verify that the Argo CD Ingress uses:

```text
ingressClassName: traefik
```

and the correct Traefik entrypoint:

```text
web
```

---

# Important Design Decisions

### Single NLB

Argo CD and Petclinic share the same AWS Network Load Balancer.

This avoids creating a separate load balancer for each application.

### Port-based routing

The architecture intentionally uses different external ports:

```text
:80    -> Argo CD
:8080  -> Petclinic
```

No application hostname is required.

### Argo CD manages applications

Petclinic should be deployed and reconciled through Argo CD rather than manually running:

```bash
helm install
helm upgrade
kubectl apply
```

This provides GitOps-based deployment and keeps the Kubernetes state synchronized with Git.

### Terraform manages infrastructure

Terraform is responsible for infrastructure such as:

- VPC
- Subnets
- EKS
- RDS
- Traefik
- AWS networking components

Argo CD is responsible for application deployment.

This separates **infrastructure lifecycle** from **application lifecycle**.

---

# Current Architecture Summary

```text
                    AWS
                     |
             +-------+-------+
             |      VPC      |
             +-------+-------+
                     |
             +-------v-------+
             |     EKS       |
             | dev-cluster    |
             +-------+-------+
                     |
        +------------+-------------+
        |                          |
   +----v-----+              +-----v------+
   | Traefik  |              |   Argo CD  |
   |   NLB    |              | GitOps CD  |
   +----+-----+              +-----+------+
        |                          |
   +----+-----+                    |
   |          |                    |
  :80       :8080                  |
   |          |                    |
   v          v                    |
Argo CD   Petclinic <--------------+
              |
              v
        Amazon RDS
         PostgreSQL
```

## Final Endpoints

```text
Argo CD:
http://aa5a471ab34464e5c9e93bab89ca4323-dbcf03ce92547897.elb.us-east-1.amazonaws.com/

Petclinic:
http://aa5a471ab34464e5c9e93bab89ca4323-dbcf03ce92547897.elb.us-east-1.amazonaws.com:8080/
```

> The exact accessibility of these endpoints depends on the current Traefik HTTP/HTTPS redirect configuration and the corresponding Argo CD/Petclinic Ingress configuration.