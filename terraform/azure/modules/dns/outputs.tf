output "application_hostname" {
  description = "Hostname that points to the Traefik LoadBalancer"
  value       = local.application_hostname
}

output "dns_zone_name" {
  description = "Name of the Azure DNS zone"
  value       = azurerm_dns_zone.this.name
}

output "name_servers" {
  description = "Name servers for the Azure DNS zone"
  value       = azurerm_dns_zone.this.name_servers
}
