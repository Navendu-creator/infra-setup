output "namespace" {
  description = "Kubernetes namespace of the sample application"
  value       = kubernetes_namespace.app.metadata[0].name
}

output "app_name" {
  description = "Name of the sample application"
  value       = var.app_name
}

output "service_name" {
  description = "Name of the Kubernetes service"
  value       = kubernetes_service.app.metadata[0].name
}

output "ingress_name" {
  description = "Name of the Kubernetes ingress"
  value       = kubernetes_ingress_v1.app.metadata[0].name
}
