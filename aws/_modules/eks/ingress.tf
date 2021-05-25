resource "aws_route53_zone" "current" {
  count = var.disable_default_ingress ? 0 : 1

  name = "${var.metadata_fqdn}."
}
