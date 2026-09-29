# Create namespace for Traefik
resource "kubernetes_namespace" "traefik" {
  metadata {
    name = var.namespace

    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

# Deploy Traefik using Helm
resource "helm_release" "traefik" {
  name       = "traefik"
  repository = "https://traefik.github.io/charts"
  chart      = "traefik"
  version    = "27.0.2"
  namespace  = kubernetes_namespace.traefik.metadata[0].name

  # Deployment
  set {
    name  = "deployment.kind"
    value = "Deployment"
  }

  set {
    name  = "deployment.replicas"
    value = "1"
  }

  # Service
  set {
    name  = "service.type"
    value = "LoadBalancer"
  }

  # AWS NLB
  set {
    name  = "service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-scheme"
    value = "internet-facing"
  }

  set {
    name  = "service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "nlb"
  }

  # Traefik dashboard/internal
  set {
    name  = "ports.traefik.port"
    value = "9000"
  }

  # ArgoCD - HTTP port 80

 
  # Petclinic - HTTP port 8080
set {
  name  = "ports.petclinic.port"
  value = "8080"
}

set {
  name  = "ports.petclinic.exposedPort"
  value = "8080"
}

set {
  name  = "ports.petclinic.expose.default"
  value = "true"
}
  
  # HTTPS port 443
  set {
    name  = "ports.websecure.port"
    value = "8443"
  }

  set {
    name  = "ports.websecure.exposedPort"
    value = "443"
  }

  # Petclinic - HTTP port 8080
  set {
    name  = "ports.petclinic.port"
    value = "8080"
  }

  set {
    name  = "ports.petclinic.exposedPort"
    value = "8080"
  }

  set {
    name  = "ports.petclinic.expose.default"
    value = "true"
  }

  # HTTP -> HTTPS redirect
  set {
    name  = "ports.web.redirectTo.port"
    value = "websecure"
  }

  # Resource limits
  set {
    name  = "resources.requests.cpu"
    value = "100m"
  }

  set {
    name  = "resources.requests.memory"
    value = "128Mi"
  }

  set {
    name  = "resources.limits.cpu"
    value = "500m"
  }

  set {
    name  = "resources.limits.memory"
    value = "256Mi"
  }

  depends_on = [
    kubernetes_namespace.traefik
  ]
}
resource "time_sleep" "wait_for_lb" {
  create_duration = "60s"

  depends_on = [
    helm_release.traefik
  ]
}
# Wait for the LoadBalancer
data "kubernetes_service" "traefik" {
  metadata {
    name      = "traefik"
    namespace = kubernetes_namespace.traefik.metadata[0].name
  }

  depends_on = [
    helm_release.traefik
  ]
}
