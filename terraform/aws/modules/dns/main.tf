# Route 53 Hosted Zone
# NOTE: If you already have a hosted zone for this domain, import it instead of creating a new one.
# To use an existing zone, comment out the aws_route53_zone resource and use a data source:
#   data "aws_route53_zone" "this" { name = var.domain_name }
resource "aws_route53_zone" "this" {
  name = var.domain_name

  tags = merge(var.tags, {
    Name = var.domain_name
  })
}

# Route 53 Record pointing to the Traefik LoadBalancer
resource "aws_route53_record" "app" {
  zone_id = aws_route53_zone.this.zone_id
  name    = var.domain_name
  type    = "CNAME"
  ttl     = 60
  records = [var.load_balancer_hostname]
}

# Output the full hostname
locals {
  application_hostname = var.domain_name
}
