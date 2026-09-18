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
  # Azure will provision a Standard Load Balancer with a public IP
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
    name  = "ports.web.redirectTo.port""
    value = "websecure"
  }

  # Azure-specific annotations for the LoadBalancer
  # Use Standard SKU Load Balancer (AKS default)
  set {
    name  = "service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-internal"
    value = "false"
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

# Wait for the LoadBalancer to get an external IP
resource "kubernetes_service" "traefik_data" {
  metadata {
    name      = "traefik"
    namespace = kubernetes_namespace.traefik.metadata[0].name
  }

  wait_for_load_balancer = true

  depends_on = [helm_release.traefik]
}
