variable "cluster_name" {
  description = "Name of the EKS cluster. CHANGE THIS to match your naming convention."
  type        = string
  default     = "dev-cluster"
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.29"
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs of the private subnets for EKS"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "IDs of the public subnets (for load balancers)"
  type        = list(string)
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC (for security group rules)"
  type        = string
}

variable "node_instance_type" {
  description = "EC2 instance type for worker nodes. Development-appropriate size."
  type        = string
  default     = "t3.medium"
}

variable "node_disk_size" {
  description = "Disk size (GB) for worker nodes"
  type        = number
  default     = 50
}

variable "node_count" {
  description = "Number of worker nodes. Assignment requires exactly 1."
  type        = number
  default     = 1
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
