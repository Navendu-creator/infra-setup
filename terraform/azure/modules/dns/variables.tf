variable "dns_zone_name" {
  description = "Name of the DNS zone. CHANGE THIS to your domain. Example: example.com"
  type        = string
}

variable "record_name" {
  description = "Name of the DNS record. CHANGE THIS. Example: dev, staging, prod"
  type        = string
}

variable "load_balancer_ip" {
  description = "External IP of the Traefik LoadBalancer"
  type        = string
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
