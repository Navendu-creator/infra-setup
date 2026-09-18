
# Namespace for the sample application
resource "kubernetes_namespace" "app" {
  metadata {
    name = var.namespace
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

# Kubernetes Secret with database credentials
resource "kubernetes_secret" "db_credentials" {
  metadata {
    name      = "${var.app_name}-db-secret"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  data = {
    host     = var.postgres_host
    port     = tostring(var.postgres_port)
    database = var.postgres_database
    username = var.postgres_username
    password = var.postgres_password
  }

  type = "Opaque"
}

# Kubernetes Deployment for the sample application
# This is a simple nginx-based app that proves the infrastructure works.
# The app responds with "Hello from <Cloud> Kubernetes" on GET /
# and provides a /health endpoint showing database connectivity.
resource "kubernetes_deployment" "app" {
  metadata {
    name      = var.app_name
    namespace = kubernetes_namespace.app.metadata[0].name
    labels = {
      app = var.app_name
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = var.app_name
      }
    }

    template {
      metadata {
        labels = {
          app = var.app_name
        }
      }

      spec {
        container {
          name  = var.app_name
          image = var.app_image

          port {
            container_port = var.app_port
          }

          env {
            name  = "POSTGRES_HOST"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.db_credentials.metadata[0].name
                key  = "host"
              }
            }
          }

          env {
            name  = "POSTGRES_PORT"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.db_credentials.metadata[0].name
                key  = "port"
              }
            }
          }

          env {
            name  = "POSTGRES_DB"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.db_credentials.metadata[0].name
                key  = "database"
              }
            }
          }

          env {
            name  = "POSTGRES_USER"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.db_credentials.metadata[0].name
                key  = "username"
              }
            }
          }

          env {
            name  = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.db_credentials.metadata[0].name
                key  = "password"
              }
            }
          }

          env {
            name  = "CLOUD_PROVIDER"
            value = var.cloud
          }

          resources {
            requests = {
              cpu    = "50m"
              memory = "64Mi"
            }
            limits = {
              cpu    = "200m"
              memory = "128Mi"
            }
          }
        }
      }
    }
  }
}

# Kubernetes Service for the sample application
resource "kubernetes_service" "app" {
  metadata {
    name      = var.app_name
    namespace = kubernetes_namespace.app.metadata[0].name
    labels = {
      app = var.app_name
    }
  }

  spec {
    type = "ClusterIP"

    selector = {
      app = var.app_name
    }

    port {
      port        = 80
      target_port = var.app_port
      protocol    = "TCP"
    }
  }
}

# Kubernetes Ingress for the sample application
# Routes traffic from Traefik to the sample app
resource "kubernetes_ingress_v1" "app" {
  metadata {
    name      = var.app_name
    namespace = kubernetes_namespace.app.metadata[0].name
    annotations = {
      "traefik.ingress.kubernetes.io/router.entrypoints" = "web,websecure"
      "traefik.ingress.kubernetes.io/router.tls"          = "true"
    }
    labels = {
      app = var.app_name
    }
  }

  spec {
    ingress_class_name = "traefik"

    rule {
      host = var.application_hostname

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.app.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [kubernetes_deployment.app]
}
