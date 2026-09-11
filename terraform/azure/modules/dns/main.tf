# Azure DNS Zone
# NOTE: If you already have a DNS zone for this domain, comment out the resource
# and use a data source instead:
#   data "azurerm_dns_zone" "this" { name = var.dns_zone_name resource_group_name = var.resource_group_name }
resource "azurerm_dns_zone" "this" {
  name                = var.dns_zone_name
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# A Record pointing to the Traefik LoadBalancer IP
resource "azurerm_dns_a_record" "app" {
  name                = var.record_name
  zone_name           = azurerm_dns_zone.this.name
  resource_group_name = var.resource_group_name
  ttl                 = 60
  records             = [var.load_balancer_ip]

  tags = var.tags
}

# Build the full hostname
locals {
  application_hostname = var.record_name == "@" ? var.dns_zone_name : "${var.record_name}.${var.dns_zone_name}"
}
