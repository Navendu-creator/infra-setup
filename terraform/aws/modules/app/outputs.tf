output "namespace" {
  description = "Kubernetes namespace for the Petclinic application"
  value       = kubernetes_namespace.app.metadata[0].name
}

output "secret_name" {
  description = "Kubernetes secret containing Petclinic database credentials"
  value       = kubernetes_secret.db_credentials.metadata[0].name
}