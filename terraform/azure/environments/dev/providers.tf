provider "azurerm" {
  features {}

  # CHANGE THIS: Uncomment and set your subscription ID, or use ARM_SUBSCRIPTION_ID env var
  # subscription_id = "your-subscription-id"
}

data "azurerm_client_config" "current" {}
