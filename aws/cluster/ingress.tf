resource "aws_route53_zone" "current" {
  count = local.disable_default_ingress ? 0 : 1

  name = "${module.cluster_metadata.fqdn}."
}
