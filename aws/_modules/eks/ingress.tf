resource "kubernetes_service" "current" {
  count = var.disable_default_ingress ? 0 : 1

  provider = kubernetes.eks

  metadata {
    name      = "ingress-kbst-default"
    namespace = "ingress-kbst-default"
  }

  spec {
    type = "LoadBalancer"

    selector = {
      "kubestack.com/ingress-default" = "true"
    }

    port {
      name        = "http"
      port        = 80
      target_port = "http"
    }

    port {
      name        = "https"
      port        = 443
      target_port = "https"
    }
  }

  depends_on = [module.cluster_services]
}

resource "aws_route53_zone" "current" {
  count = var.disable_default_ingress ? 0 : 1

  name = "${var.metadata_fqdn}."
}

data "aws_elb_hosted_zone_id" "current" {
  count = var.disable_default_ingress ? 0 : 1
}

resource "aws_route53_record" "host" {
  count = var.disable_default_ingress ? 0 : 1

  zone_id = aws_route53_zone.current[0].zone_id
  name    = var.metadata_fqdn
  type    = "A"

  alias {
    name                   = kubernetes_service.current[0].load_balancer_ingress[0].hostname
    zone_id                = data.aws_elb_hosted_zone_id.current[0].id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "wildcard" {
  count = var.disable_default_ingress ? 0 : 1

  zone_id = aws_route53_zone.current[0].zone_id
  name    = "*.${var.metadata_fqdn}"
  type    = "A"

  alias {
    name                   = kubernetes_service.current[0].load_balancer_ingress[0].hostname
    zone_id                = data.aws_elb_hosted_zone_id.current[0].id
    evaluate_target_health = true
  }
}
