resource "digitalocean_floating_ip" "current" {
 region  = "${var.region}"
}

resource "kubernetes_namespace" "current" {
  provider = "kubernetes.do_ks"

  metadata {
    name = "ingress-nginx"
  }

  depends_on = ["digitalocean_kubernetes_cluster.current"]
}

resource "kubernetes_service" "current" {
  provider = "kubernetes.do_ks"

  metadata {
    name      = "ingress-nginx"
    namespace = "${kubernetes_namespace.current.metadata.0.name}"
  }

  spec {
    type             = "LoadBalancer"
    load_balancer_ip = "${digitalocean_floating_ip.current.ip_address}"

    selector {
      "app.kubernetes.io/name"    = "ingress-nginx"
      "app.kubernetes.io/part-of" = "ingress-nginx"
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
