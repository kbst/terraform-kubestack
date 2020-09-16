output "default_ingress_nameservers" {
  value = var.disable_default_ingress ? null : aws_route53_zone.current[0].name_servers
}
