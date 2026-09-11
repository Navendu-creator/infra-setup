variable "namespace" {
  description = "Kubernetes namespace for the sample application"
  type        = string
  default     = "sample-app"
}

variable "app_name" {
  description = "Name of the sample application"
  type        = string
  default     = "hello-app"
}

variable "app_image" {
  description = "Container image for the sample application"
  type        = string
  default     = "nginx:1.25-alpine"
}

variable "app_port" {
  description = "Port the application listens on"
  type        = number
  default     = 8080
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
  description = "Password for the PostgreSQL database (sensitive)"
  type        = string
  sensitive   = true
}

variable "secret_arn" {
  description = "ARN of the AWS Secrets Manager secret (for reference)"
  type        = string
}

variable "application_hostname" {
  description = "Hostname for the application (used in ingress)"
  type        = string
}

variable "cloud" {
  description = "Cloud provider name (for the response message)"
  type        = string
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
