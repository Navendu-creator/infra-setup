variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "vpc_name" {
  description = "Name of the VPC. CHANGE THIS to match your naming convention."
  type        = string
  default     = "prod-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.2.0.0/16"
}

variable "cluster_name" {
  description = "Name of the EKS cluster. CHANGE THIS to match your naming convention."
  type        = string
  default     = "prod-cluster"
}

variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.29"
}

variable "node_instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
  default     = "t3.large"
}

variable "node_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 1
}

variable "postgres_name" {
  description = "Identifier for the RDS instance. CHANGE THIS to match your naming convention."
  type        = string
  default     = "prod-postgres"
}

variable "postgres_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.medium"
}

variable "postgres_engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "15"
}

variable "database_name" {
  description = "Name of the database to create"
  type        = string
  default     = "appdb"
}

variable "database_username" {
  description = "Master username for the database"
  type        = string
  default     = "dbadmin"
}

variable "domain_name" {
  description = "Domain name for the application. CHANGE THIS to your registered domain."
  type        = string
  default     = "prod.example.com"
}

variable "project_name" {
  description = "Project name used in tags"
  type        = string
  default     = "cloud-support-engineering"
}
