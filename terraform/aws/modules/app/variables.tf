variable "namespace" {
  description = "Kubernetes namespace for the Petclinic application"
  type        = string
  default     = "petclinic"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "petclinic"
}

variable "postgres_host" {
  description = "Endpoint of the PostgreSQL database"
  type        = string
}

variable "postgres_port" {
  description = "Port for the PostgreSQL database"
  type        = number
}

variable "postgres_database" {
  description = "Name of the PostgreSQL database"
  type        = string
}

variable "postgres_username" {
  description = "Username for the PostgreSQL database"
  type        = string
}

variable "postgres_password" {
  description = "Password for the PostgreSQL database"
  type        = string
  sensitive   = true
}

variable "secret_arn" {
  description = "ARN of the AWS Secrets Manager secret"
  type        = string
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}