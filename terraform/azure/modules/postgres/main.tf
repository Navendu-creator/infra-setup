# Generate random password for the database admin user
resource "random_password" "db_password" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Store the password in Azure Key Vault
# NOTE: Key Vault must be created before this module, or create it here.
# The Key Vault is created in the root main.tf and passed as variables.
# For simplicity, we store the password in a Key Vault secret.

# PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server" "this" {
  name                   = var.postgres_name
  resource_group_name    = var.resource_group_name
  location               = var.location
  version                = var.postgres_version
  administrator_login    = var.admin_username
  administrator_password = random_password.db_password.result
  storage_mb             = var.storage_mb
  sku_name               = var.sku_name
  delegated_subnet_id    = var.subnet_id
  private_dns_zone_id    = var.private_dns_zone_id

  # No public access - only accessible from within the VNet
  public_network_access_enabled = false

  tags = merge(var.tags, {
    Name = var.postgres_name
  })
}

# PostgreSQL Database
resource "azurerm_postgresql_flexible_server_database" "this" {
  name      = var.database_name
  server_id = azurerm_postgresql_flexible_server.this.id
  charset   = "UTF8"
  collation = "en_US.utf8"

  depends_on = [azurerm_postgresql_flexible_server.this]
}

# PostgreSQL Firewall Rule (not needed - using private access)
# Public access is disabled. The database is only accessible from within the VNet.
