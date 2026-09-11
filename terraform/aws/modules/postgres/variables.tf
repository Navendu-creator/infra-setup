variable "postgres_name" {
  description = "Identifier for the RDS instance. CHANGE THIS to match your naming convention."
  type        = string
  default     = "dev-postgres"
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "db_subnet_group_name" {
  description = "Name of the RDS subnet group"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC (for security group rules)"
  type        = string
}

variable "engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "15"
}

variable "instance_class" {
  description = "RDS instance class. Development-appropriate size."
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
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

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}
