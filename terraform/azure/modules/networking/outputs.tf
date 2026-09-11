output "vnet_id" {
  description = "ID of the Virtual Network"
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "Name of the Virtual Network"
  value       = azurerm_virtual_network.this.name
}

output "aks_subnet_id" {
  description = "ID of the AKS subnet"
  value       = azurerm_subnet.aks.id
}

output "postgres_subnet_id" {
  description = "ID of the PostgreSQL subnet"
  value       = azurerm_subnet.postgres.id
}

output "vnet_address_space" {
  description = "Address space of the VNet"
  value       = azurerm_virtual_network.this.address_space
}

output "private_dns_zone_id" {
  description = "ID of the Private DNS Zone for PostgreSQL"
  value       = azurerm_private_dns_zone.postgres.id
}
