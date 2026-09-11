# User Assigned Managed Identity for AKS
resource "azurerm_user_assigned_identity" "aks" {
  name                = "${var.cluster_name}-identity"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# AKS Cluster
resource "azurerm_kubernetes_cluster" "this" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  kubernetes_version  = var.kubernetes_version
  dns_prefix          = var.cluster_name

  # Managed Identity (not service principal)
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks.id]
  }

  # Default node pool - one worker node
  default_node_pool {
    name                = "systempool"
    node_count          = var.node_count
    vm_size             = var.node_vm_size
    vnet_subnet_id      = var.aks_subnet_id
    type                = "VirtualMachineScaleSets"
    os_sku              = "Ubuntu"
    enable_auto_scaling = false

    tags = var.tags
  }

  # Network profile - use Azure CNI
  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "Standard"
    service_cidr      = "10.10.0.0/16"
    dns_service_ip    = "10.10.0.10"
  }

  # Enable HTTP application routing add-on (provides Azure-provided DNS)
  http_application_routing_enabled = true

  tags = merge(var.tags, {
    Name = var.cluster_name
  })
}

# Role assignment for the AKS managed identity to read from ACR
# Uncomment if you have an Azure Container Registry
# resource "azurerm_role_assignment" "acr" {
#   scope                = azurerm_container_registry.example.id
#   role_definition_name  = "AcrPull"
#   principal_id         = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
# }

# Kubernetes provider configuration
provider "kubernetes" {
  host = azurerm_kubernetes_cluster.this.kube_config[0].host

  client_certificate     = base64decode(azurerm_kubernetes_cluster.this.kube_config[0].client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.this.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.this.kube_config[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host = azurerm_kubernetes_cluster.this.kube_config[0].host

    client_certificate     = base64decode(azurerm_kubernetes_cluster.this.kube_config[0].client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.this.kube_config[0].client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.this.kube_config[0].cluster_ca_certificate)
  }
}

provider "kubectl" {
  host = azurerm_kubernetes_cluster.this.kube_config[0].host

  client_certificate     = base64decode(azurerm_kubernetes_cluster.this.kube_config[0].client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.this.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.this.kube_config[0].cluster_ca_certificate)
  load_config_file       = false
}
