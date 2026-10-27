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
  description = "Number of worker nodes"
  type        = number
  default     = 1
}

variable "node_capacity_type" {
  description = "Capacity type for worker nodes: ON_DEMAND or SPOT"
  type        = string
  default     = "ON_DEMAND"

  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.node_capacity_type)
    error_message = "node_capacity_type must be ON_DEMAND or SPOT."
  }
}

variable "node_subnet_ids" {
  description = "Subnets for worker nodes. Defaults to private_subnet_ids; use public subnets when there is no NAT gateway."
  type        = list(string)
  default     = null
}

variable "cluster_log_types" {
  description = "EKS control plane log types to send to CloudWatch. Set to [] to save cost."
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "cluster_admin_arns" {
  description = "IAM user/role ARNs granted cluster admin. Defaults to the identity running Terraform."
  type        = list(string)
  default     = []
}

variable "enable_ebs_csi_driver" {
  description = "Install the EBS CSI driver add-on (with Pod Identity) and a default gp3 StorageClass"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
