variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "East US"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "staging"
}

variable "resource_group_name" {
  description = "Name of the resource group. CHANGE THIS to match your naming convention."
  type        = string
  default     = "staging-rg"
}

variable "vnet_name" {
  description = "Name of the Virtual Network. CHANGE THIS to match your naming convention."
  type        = string
  default     = "staging-vnet"
}

variable "vnet_address_space" {
  description = "Address space for the VNet"
  type        = list(string)
  default     = ["10.1.0.0/16"]
}

variable "aks_subnet_cidr" {
  description = "CIDR for the AKS subnet"
  type        = string
  default     = "10.1.1.0/24"
}

variable "postgres_subnet_cidr" {
  description = "CIDR for the PostgreSQL subnet"
  type        = string
  default     = "10.1.2.0/24"
}

variable "cluster_name" {
  description = "Name of the AKS cluster. CHANGE THIS to match your naming convention."
  type        = string
  default     = "staging-cluster"
}

variable "kubernetes_version" {
  description = "Kubernetes version for the AKS cluster"
  type        = string
  default     = "1.29"
}

variable "node_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 1
}

variable "node_vm_size" {
  description = "VM size for worker nodes"
  type        = string
  default     = "Standard_B2s"
}

variable "postgres_name" {
  description = "Name of the PostgreSQL Flexible Server. CHANGE THIS to match your naming convention."
  type        = string
  default     = "staging-pgserver"
}

variable "postgres_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "15"
}

variable "postgres_sku_name" {
  description = "SKU for the PostgreSQL Flexible Server"
  type        = string
  default     = "GP_Standard_D2s_v3"
}

variable "postgres_storage_mb" {
  description = "Storage in MB for the PostgreSQL server"
  type        = number
  default     = 65536
}

variable "database_name" {
  description = "Name of the database to create"
  type        = string
  default     = "appdb"
}

variable "admin_username" {
  description = "Admin username for the PostgreSQL server"
  type        = string
  default     = "dbadmin"
}

variable "dns_zone_name" {
  description = "Name of the Azure DNS zone. CHANGE THIS to your registered domain."
  type        = string
  default     = "example.com"
}

variable "dns_record_name" {
  description = "Name of the DNS A record. CHANGE THIS."
  type        = string
  default     = "staging"
}

variable "key_vault_name" {
  description = "Name of the Azure Key Vault for secrets. CHANGE THIS to a globally unique name."
  type        = string
  default     = "staging-keyvault-12345"
}

variable "project_name" {
  description = "Project name used in tags"
  type        = string
  default     = "cloud-support-engineering"
}
