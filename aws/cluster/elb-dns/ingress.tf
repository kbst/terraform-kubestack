data "kubernetes_service" "current" {
  metadata {
    name      = var.ingress_service_name
    namespace = var.ingress_service_namespace
  }
}

data "aws_route53_zone" "current" {
  name = "${var.metadata_fqdn}."
}

data "aws_elb_hosted_zone_id" "current" {
}

resource "aws_route53_record" "host" {
  zone_id = data.aws_route53_zone.current.zone_id
  name    = var.metadata_fqdn
  type    = "A"

  alias {
    name                   = data.kubernetes_service.current.status[0].load_balancer[0].ingress[0].hostname
    zone_id                = data.aws_elb_hosted_zone_id.current.id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "wildcard" {
  zone_id = data.aws_route53_zone.current.zone_id
  name    = "*.${var.metadata_fqdn}"
  type    = "A"

  alias {
    name                   = data.kubernetes_service.current.status[0].load_balancer[0].ingress[0].hostname
    zone_id                = data.aws_elb_hosted_zone_id.current.id
    evaluate_target_health = true
  }
}
