output "fqdn" {
  description = "FQDN of the PostgreSQL Flexible Server"
  value       = azurerm_postgresql_flexible_server.this.fqdn
}

output "server_name" {
  description = "Name of the PostgreSQL Flexible Server"
  value       = azurerm_postgresql_flexible_server.this.name
}

output "database_name" {
  description = "Name of the database"
  value       = azurerm_postgresql_flexible_server_database.this.name
}

output "admin_username" {
  description = "Admin username for the PostgreSQL server"
  value       = var.admin_username
}

output "admin_password" {
  description = "Admin password for the PostgreSQL server (sensitive)"
  value       = random_password.db_password.result
  sensitive   = true
}

output "connection_string" {
  description = "PostgreSQL connection string (sensitive)"
  value       = "postgresql://${var.admin_username}:${random_password.db_password.result}@${azurerm_postgresql_flexible_server.this.fqdn}:5432/${var.database_name}"
  sensitive   = true
}
