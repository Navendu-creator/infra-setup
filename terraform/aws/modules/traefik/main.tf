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

  set {
    name  = "deployment.kind"
    value = "Deployment"
  }

  set {
    name  = "deployment.replicas"
    value = "1"
  }

  # Expose Traefik via a LoadBalancer service
  # AWS will provision a Classic Load Balancer or NLB
  set {
    name  = "service.type"
    value = "LoadBalancer"
  }

  # Enable HTTP (port 80) and HTTPS (port 443)
  set {
    name  = "ports.traefik.port"
    value = "9000"
  }

  set {
    name  = "ports.web.port"
    value = "8000"
  }

  set {
    name  = "ports.web.exposedPort"
    value = "80"
  }

  set {
    name  = "ports.websecure.port"
    value = "8443"
  }

  set {
    name  = "ports.websecure.exposedPort"
    value = "443"
  }

  # Enable SSL redirection
  set {
    name  = "ports.web.redirectTo"
    value = "websecure"
  }

  # AWS-specific annotations for the LoadBalancer
  set {
    name  = "service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "nlb"
  }

  set {
    name  = "service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-scheme"
    value = "internet-facing"
  }

  # Resource limits for development
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

  depends_on = [kubernetes_namespace.traefik]
}

# Wait for the LoadBalancer to get an external hostname
resource "kubernetes_service" "traefik_data" {
  metadata {
    name      = "traefik"
    namespace = kubernetes_namespace.traefik.metadata[0].name
  }

  wait_for_load_balancer = true

  depends_on = [helm_release.traefik]
}
