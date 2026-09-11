variable "cluster_name" {
  description = "Name of the AKS cluster. CHANGE THIS to match your naming convention."
  type        = string
  default     = "dev-cluster"
}

variable "kubernetes_version" {
  description = "Kubernetes version for the AKS cluster"
  type        = string
  default     = "1.29"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "aks_subnet_id" {
  description = "ID of the AKS subnet"
  type        = string
}

variable "node_count" {
  description = "Number of worker nodes. Assignment requires exactly 1."
  type        = number
  default     = 1
}

variable "node_vm_size" {
  description = "VM size for worker nodes. Development-appropriate size."
  type        = string
  default     = "Standard_B2s"
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
