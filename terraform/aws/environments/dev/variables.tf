variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_name" {
  description = "Name of the VPC. CHANGE THIS to match your naming convention."
  type        = string
  default     = "dev-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "cluster_name" {
  description = "Name of the EKS cluster. CHANGE THIS to match your naming convention."
  type        = string
  default     = "dev-cluster"
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster. Versions in extended support cost 6x more."
  type        = string
  default     = "1.34"
}

variable "node_instance_type" {
  description = "EC2 instance type for worker nodes. Wazuh indexer needs at least 8 GB RAM per node."
  type        = string
  default     = "t3.large"
}

variable "node_capacity_type" {
  description = "ON_DEMAND or SPOT. SPOT is ~60-70% cheaper but nodes can be reclaimed."
  type        = string
  default     = "SPOT"
}

variable "node_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 2
}

variable "node_disk_size" {
  description = "Root disk size (GB) for worker nodes. Wazuh data lives on separate EBS volumes."
  type        = number
  default     = 30
}

variable "cluster_admin_arns" {
  description = "IAM user/role ARNs granted EKS cluster admin (e.g. your user and the GitHub Actions user). Empty = whoever runs Terraform."
  type        = list(string)
  default     = []
}

variable "project_name" {
  description = "Project name used in tags"
  type        = string
  default     = "cloud-support-engineering"
}
