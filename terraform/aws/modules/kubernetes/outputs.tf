output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "Endpoint of the EKS cluster"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_ca_certificate" {
  description = "CA certificate of the EKS cluster (base64 encoded)"
  value       = aws_eks_cluster.this.certificate_authority[0].data
  sensitive   = true
}

output "cluster_arn" {
  description = "ARN of the EKS cluster"
  value       = aws_eks_cluster.this.arn
}

output "node_group_name" {
  description = "Name of the EKS node group"
  value       = aws_eks_node_group.this.node_group_name
}

output "node_role_arn" {
  description = "ARN of the EKS node IAM role"
  value       = aws_iam_role.node.arn
}
output "access_ready" {
  value      = true
  depends_on = [time_sleep.wait_for_access_propagation]
}