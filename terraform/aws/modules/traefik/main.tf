
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

  # Expose Traefik through AWS LoadBalancer
  set {
    name  = "service.type"
    value = "LoadBalancer"
  }

  # Traefik internal port
  set {
    name  = "ports.traefik.port"
    value = "9000"
  }

  # HTTP
  set {
    name  = "ports.web.port"
    value = "8000"
  }

  set {
    name  = "ports.web.exposedPort"
    value = "80"
  }

  # HTTPS
  set {
    name  = "ports.websecure.port"
    value = "8443"
  }

  set {
    name  = "ports.websecure.exposedPort"
    value = "443"
  }

  # Redirect HTTP -> HTTPS
  set {
    name  = "ports.web.redirectTo.port"
    value = "websecure"
  }

  # AWS LoadBalancer configuration
  set {
    name  = "service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "nlb"
  }

  set {
    name  = "service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-scheme"
    value = "internet-facing"
  }

  # Resource requests
  set {
    name  = "resources.requests.cpu"
    value = "100m"
  }

  set {
    name  = "resources.requests.memory"
    value = "128Mi"
  }

  # Resource limits
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

# Read the Traefik Service after LoadBalancer provisioning
data "kubernetes_service" "traefik" {
  metadata {
    name      = "traefik"
    namespace = var.namespace
  }

  depends_on = [
    time_sleep.wait_for_lb
  ]
}


# Wait for AWS LoadBalancer to be provisioned
resource "time_sleep" "wait_for_lb" {
  create_duration = "60s"

  depends_on = [
    helm_release.traefik
  ]
}

