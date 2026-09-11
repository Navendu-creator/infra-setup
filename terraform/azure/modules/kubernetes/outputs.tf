output "cluster_name" {
  description = "Name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.name
}

output "cluster_id" {
  description = "ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.id
}

output "kube_config" {
  description = "Kubeconfig for the AKS cluster (sensitive)"
  value       = azurerm_kubernetes_cluster.this.kube_config_raw
  sensitive   = true
}

output "kube_admin_config" {
  description = "Admin kubeconfig for the AKS cluster (sensitive)"
  value       = azurerm_kubernetes_cluster.this.kube_admin_config_raw
  sensitive   = true
}

output "http_application_routing_zone_name" {
  description = "Azure-provided DNS zone for HTTP application routing"
  value       = azurerm_kubernetes_cluster.this.http_application_routing_zone_name
}

output "node_resource_group" {
  description = "Auto-created resource group for AKS nodes"
  value       = azurerm_kubernetes_cluster.this.node_resource_group
}

output "identity_id" {
  description = "ID of the AKS managed identity"
  value       = azurerm_user_assigned_identity.aks.id
}

output "identity_principal_id" {
  description = "Principal ID of the AKS managed identity"
  value       = azurerm_user_assigned_identity.aks.principal_id
}
