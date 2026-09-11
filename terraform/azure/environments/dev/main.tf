locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

# Resource Group
resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.common_tags
}

# Key Vault for storing database credentials
# NOTE: Key Vault name must be globally unique. CHANGE var.key_vault_name.
resource "azurerm_key_vault" "this" {
  name                       = var.key_vault_name
  location                   = var.location
  resource_group_name        = azurerm_resource_group.this.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get", "Set", "List", "Delete", "Purge", "Recover"
    ]
  }

  tags = local.common_tags
}

# Networking Module
module "networking" {
  source = "../../modules/networking"

  vnet_name              = var.vnet_name
  vnet_address_space     = var.vnet_address_space
  aks_subnet_cidr        = var.aks_subnet_cidr
  postgres_subnet_cidr   = var.postgres_subnet_cidr
  resource_group_name    = azurerm_resource_group.this.name
  location               = var.location
  tags                   = local.common_tags
}

# Kubernetes Module
module "kubernetes" {
  source = "../../modules/kubernetes"

  cluster_name        = var.cluster_name
  kubernetes_version  = var.kubernetes_version
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  aks_subnet_id       = module.networking.aks_subnet_id
  node_count          = var.node_count
  node_vm_size        = var.node_vm_size
  tags                = local.common_tags
}

# PostgreSQL Module
module "postgres" {
  source = "../../modules/postgres"

  postgres_name        = var.postgres_name
  resource_group_name  = azurerm_resource_group.this.name
  location              = var.location
  subnet_id            = module.networking.postgres_subnet_id
  private_dns_zone_id  = module.networking.private_dns_zone_id
  postgres_version      = var.postgres_version
  sku_name              = var.postgres_sku_name
  storage_mb            = var.postgres_storage_mb
  database_name         = var.database_name
  admin_username         = var.admin_username
  tags                  = local.common_tags
}

# Store database credentials in Key Vault
resource "azurerm_key_vault_secret" "db_password" {
  name         = "${var.postgres_name}-password"
  value        = module.postgres.admin_password
  key_vault_id = azurerm_key_vault.this.id

  depends_on = [module.postgres]
}

# Traefik Module
module "traefik" {
  source = "../../modules/traefik"

  cluster_name = var.cluster_name
  tags         = local.common_tags
}

# DNS Module
module "dns" {
  source = "../../modules/dns"

  dns_zone_name        = var.dns_zone_name
  record_name          = var.dns_record_name
  load_balancer_ip     = module.traefik.load_balancer_ip
  resource_group_name  = azurerm_resource_group.this.name
  location             = var.location
  tags                 = local.common_tags
}

# Application Module
module "app" {
  source = "../../modules/app"

  postgres_host        = module.postgres.fqdn
  postgres_port        = 5432
  postgres_database    = module.postgres.database_name
  postgres_username    = module.postgres.admin_username
  postgres_password    = module.postgres.admin_password
  application_hostname = module.dns.application_hostname
  cloud                = "Azure"
  tags                 = local.common_tags
}
