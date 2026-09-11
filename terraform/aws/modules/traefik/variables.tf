variable "namespace" {
  description = "Kubernetes namespace for Traefik"
  type        = string
  default     = "traefik"
}

variable "cluster_name" {
  description = "Name of the EKS cluster (for tagging)"
  type        = string
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
