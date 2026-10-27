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

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "kubernetes_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.kubernetes.cluster_name
}

output "cluster_endpoint" {
  value = module.kubernetes.cluster_endpoint
}

output "cluster_name" {
  value = module.kubernetes.cluster_name
}

output "kubeconfig_command" {
  description = "Command to configure kubectl for this cluster"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.kubernetes.cluster_name}"
}
