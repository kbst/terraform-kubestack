output "name_servers" {
  value = ingress.aws_route53.zone.current.name_servers
}
