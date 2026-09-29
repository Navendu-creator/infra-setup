output "traefik_nlb_dns" {
  description = "Existing Traefik NLB DNS name"
  value       = local.traefik_nlb_dns
}

output "argocd_url" {
  description = "ArgoCD URL through existing Traefik NLB"
  value       = "http://${local.traefik_nlb_dns}"
}