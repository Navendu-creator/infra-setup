terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }

  # CHANGE THIS: Configure your Azure Storage backend for state storage
  # backend "azurerm" {
  #   resource_group_name  = "your-terraform-state-rg"
  #   storage_account_name = "yourterraformstate"
  #   container_name       = "tfstate"
  #   key                  = "azure/dev/terraform.tfstate"
  # }
}
