output "namespace" {
  description = "Kubernetes namespace where Traefik is deployed"
  value       = kubernetes_namespace.traefik.metadata[0].name
}

output "load_balancer_hostname" {
  description = "External hostname of the Traefik LoadBalancer"

  value = try(
    data.kubernetes_service.traefik.status[0].load_balancer[0].ingress[0].hostname,
    null
  )
}

output "helm_release_name" {
  description = "Name of the Traefik Helm release"
  value       = helm_release.traefik.name
}