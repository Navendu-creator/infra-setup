output "cloud" {
  description = "Cloud provider"
  value       = "AWS"
}

output "region" {
  description = "AWS region"
  value       = var.aws_region
}

output "resource_prefix" {
  description = "Resource prefix used for all resources"
  value       = var.vpc_name
}

output "kubernetes_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.kubernetes.cluster_name
}

output "postgres_endpoint" {
  description = "Endpoint of the RDS PostgreSQL instance"
  value       = module.postgres.endpoint
}

output "postgres_database_name" {
  description = "Name of the database"
  value       = module.postgres.database_name
}

output "postgres_secret_arn" {
  description = "ARN of the AWS Secrets Manager secret containing database credentials"
  value       = module.postgres.secret_arn
  sensitive   = true
}

output "traefik_public_hostname" {
  description = "External hostname of the Traefik LoadBalancer"
  value       = module.traefik.load_balancer_hostname
}

output "application_url" {
  description = "Full URL to access the application"
  value       = module.traefik.load_balancer_hostname != null ? "http://${module.traefik.load_balancer_hostname}" : "pending - LB hostname not yet available, re-run terraform apply"
}

output "cluster_endpoint" {
  value = module.kubernetes.cluster_endpoint
}

output "cluster_name" {
  value = module.kubernetes.cluster_name
}

