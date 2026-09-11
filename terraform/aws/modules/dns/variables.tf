variable "domain_name" {
  description = "Domain name to use for the application. CHANGE THIS to your registered domain. Example: app.example.com"
  type        = string
}

variable "load_balancer_hostname" {
  description = "External hostname of the Traefik LoadBalancer"
  type        = string
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
