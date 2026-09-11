variable "vnet_name" {
  description = "Name of the Virtual Network. CHANGE THIS to match your naming convention."
  type        = string
  default     = "dev-vnet"
}

variable "vnet_address_space" {
  description = "Address space for the VNet"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "aks_subnet_cidr" {
  description = "CIDR for the AKS subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "postgres_subnet_cidr" {
  description = "CIDR for the PostgreSQL subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
