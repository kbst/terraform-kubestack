output "ingress_zone_name_servers" {
  value       = aws_route53_zone.current.name_servers
  description = "Nameservers of the cluster's managed zone."
}

