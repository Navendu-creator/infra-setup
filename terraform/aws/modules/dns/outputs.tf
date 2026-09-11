output "application_hostname" {
  description = "Hostname that points to the Traefik LoadBalancer"
  value       = local.application_hostname
}

output "zone_id" {
  description = "ID of the Route 53 hosted zone"
  value       = aws_route53_zone.this.zone_id
}

output "name_servers" {
  description = "Name servers for the Route 53 hosted zone"
  value       = aws_route53_zone.this.name_servers
}
