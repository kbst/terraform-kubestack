resource "aws_route53_zone" "current" {
  count = try(coalesce(local.cfg.disable_default_ingress, null), false) ? 0 : 1

  name = "${module.cluster_metadata.fqdn}."
}
