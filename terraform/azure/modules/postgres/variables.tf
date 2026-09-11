variable "postgres_name" {
  description = "Name of the PostgreSQL Flexible Server. CHANGE THIS to match your naming convention."
  type        = string
  default     = "dev-postgres"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "subnet_id" {
  description = "ID of the PostgreSQL subnet"
  type        = string
}

variable "private_dns_zone_id" {
  description = "ID of the Private DNS Zone for PostgreSQL"
  type        = string
}

variable "postgres_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "15"
}

variable "sku_name" {
  description = "SKU for the PostgreSQL Flexible Server. Development-appropriate size."
  type        = string
  default     = "B_Standard_B1ms"
}

variable "storage_mb" {
  description = "Storage in MB for the PostgreSQL server"
  type        = number
  default     = 32768
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

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
