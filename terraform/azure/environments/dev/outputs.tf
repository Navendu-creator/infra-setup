output "cloud" {
  description = "Cloud provider"
  value       = "Azure"
}

output "region" {
  description = "Azure region"
  value       = var.location
}

output "resource_group" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.this.name
}

output "kubernetes_cluster_name" {
  description = "Name of the AKS cluster"
  value       = module.kubernetes.cluster_name
}

output "postgres_endpoint" {
  description = "FQDN of the PostgreSQL Flexible Server"
  value       = module.postgres.fqdn
}

output "postgres_database_name" {
  description = "Name of the database"
  value       = module.postgres.database_name
}

output "postgres_secret_vault_uri" {
  description = "URI of the Key Vault secret containing the database password"
  value       = azurerm_key_vault_secret.db_password.id
  sensitive   = true
}

output "traefik_public_ip" {
  description = "External IP of the Traefik LoadBalancer"
  value       = module.traefik.load_balancer_ip
}

output "application_hostname" {
  description = "Hostname that resolves to the application through Traefik"
  value       = module.dns.application_hostname
}

output "application_url" {
  description = "Full URL to access the application"
  value       = "https://${module.dns.application_hostname}"
}
