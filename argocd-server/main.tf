terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ---------------------------------------------------------
# Existing EKS cluster
# ---------------------------------------------------------

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = var.cluster_name
}

# ---------------------------------------------------------
# Kubernetes provider
# ---------------------------------------------------------

provider "kubernetes" {
  host = data.aws_eks_cluster.this.endpoint

  cluster_ca_certificate = base64decode(
    data.aws_eks_cluster.this.certificate_authority[0].data
  )

  token = data.aws_eks_cluster_auth.this.token
}

# ---------------------------------------------------------
# Helm provider
# ---------------------------------------------------------

provider "helm" {
  kubernetes = {
    host = data.aws_eks_cluster.this.endpoint

    cluster_ca_certificate = base64decode(
      data.aws_eks_cluster.this.certificate_authority[0].data
    )

    token = data.aws_eks_cluster_auth.this.token
  }
}

# ---------------------------------------------------------
# Existing Traefik service
# ---------------------------------------------------------

data "kubernetes_service" "traefik" {
  metadata {
    name      = "traefik"
    namespace = "traefik"
  }
}

# ---------------------------------------------------------
# Existing Traefik NLB DNS
# ---------------------------------------------------------

locals {
  traefik_nlb_dns = data.kubernetes_service.traefik.status[0].load_balancer[0].ingress[0].hostname
}

# ---------------------------------------------------------
# ArgoCD namespace
# ---------------------------------------------------------

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

# ---------------------------------------------------------
# ArgoCD Helm release
# ---------------------------------------------------------
resource "helm_release" "argocd" {
  name      = "argocd"
  namespace = kubernetes_namespace.argocd.metadata[0].name

  chart = "${path.module}/argo-cd-10.9.2.tgz"

  create_namespace = false

  values = [
    templatefile("${path.module}/values.yaml", {
      traefik_nlb_dns = local.traefik_nlb_dns
    })
  ]

  depends_on = [
    kubernetes_namespace.argocd
  ]
}