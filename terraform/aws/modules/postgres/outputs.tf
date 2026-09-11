output "endpoint" {
  description = "Endpoint of the RDS PostgreSQL instance"
  value       = aws_db_instance.this.address
}

output "database_name" {
  description = "Name of the database"
  value       = aws_db_instance.this.db_name
}

output "database_username" {
  description = "Master username for the database"
  value       = var.database_username
}

output "database_password" {
  description = "Master password for the database (sensitive)"
  value       = random_password.db_password.result
  sensitive   = true
}

output "secret_arn" {
  description = "ARN of the AWS Secrets Manager secret containing database credentials"
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "security_group_id" {
  description = "ID of the RDS security group"
  value       = aws_security_group.db.id
}

output "connection_string" {
  description = "PostgreSQL connection string (sensitive)"
  value       = "postgresql://${var.database_username}:${random_password.db_password.result}@${aws_db_instance.this.address}:5432/${var.database_name}"
  sensitive   = true
}
