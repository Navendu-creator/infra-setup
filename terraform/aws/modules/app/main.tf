# Namespace for the Petclinic application
resource "kubernetes_namespace" "app" {
  metadata {
    name = var.namespace

    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

# PostgreSQL credentials consumed by the Petclinic Helm chart
resource "kubernetes_secret" "db_credentials" {
  metadata {
    name      = "petclinic-db"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  data = {
    POSTGRES_USER = var.postgres_username
    POSTGRES_PASS = var.postgres_password
  }

  type = "Opaque"
}