resource "kubernetes_namespace" "current" {
  provider = kubernetes.eks

  metadata {
    name = "ingress-kbst-default"
  }

  # namespace metadata may change through the manifests
  # hence ignoring this for the terraform lifecycle
  lifecycle {
    ignore_changes = [metadata]
  }

  depends_on = [aws_eks_cluster.current]
}

resource "kubernetes_service" "current" {
  provider = kubernetes.eks

  metadata {
    name      = "ingress-kbst-default"
    namespace = kubernetes_namespace.current.metadata[0].name
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
}

resource "aws_route53_zone" "current" {
  name = "${var.metadata_fqdn}."
}

locals {
  elb_hostname = kubernetes_service.current.load_balancer_ingress[0].hostname
}

data "aws_elb_hosted_zone_id" "current" {
}

resource "aws_route53_record" "host" {
  zone_id = aws_route53_zone.current.zone_id
  name    = var.metadata_fqdn
  type    = "A"

  alias {
    name                   = local.elb_hostname
    zone_id                = data.aws_elb_hosted_zone_id.current.id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "wildcard" {
  zone_id = aws_route53_zone.current.zone_id
  name    = "*.${var.metadata_fqdn}"
  type    = "A"

  alias {
    name                   = local.elb_hostname
    zone_id                = data.aws_elb_hosted_zone_id.current.id
    evaluate_target_health = true
  }
}

