resource "azurerm_public_ip" "current" {
  name                = "${var.metadata_name}"
  location            = "${azurerm_kubernetes_cluster.current.location}"
  resource_group_name = "${azurerm_kubernetes_cluster.current.node_resource_group}"
  allocation_method   = "Static"

  tags = "${var.metadata_labels}"

  depends_on = ["azurerm_kubernetes_cluster.current"]
}

resource "kubernetes_namespace" "current" {
  provider = "kubernetes.aks"

  metadata {
    name = "ingress-nginx"
  }

  depends_on = ["azurerm_kubernetes_cluster.current"]
}

resource "kubernetes_service" "current" {
  provider = "kubernetes.aks"

  metadata {
    name      = "ingress-nginx"
    namespace = "${kubernetes_namespace.current.metadata.0.name}"
  }

  spec {
    type             = "LoadBalancer"
    load_balancer_ip = "${azurerm_public_ip.current.ip_address}"

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

resource "azurerm_dns_zone" "current" {
  name                = "${var.metadata_fqdn}"
  resource_group_name = "${data.azurerm_resource_group.current.name}"
  zone_type           = "Public"

  tags = "${var.metadata_labels}"
}

resource "azurerm_dns_a_record" "host" {
  name                = "@"
  zone_name           = "${azurerm_dns_zone.current.name}"
  resource_group_name = "${data.azurerm_resource_group.current.name}"
  ttl                 = 300
  records             = ["${azurerm_public_ip.current.ip_address}"]

  tags = "${var.metadata_labels}"
}

resource "azurerm_dns_a_record" "wildcard" {
  name                = "*"
  zone_name           = "${azurerm_dns_zone.current.name}"
  resource_group_name = "${data.azurerm_resource_group.current.name}"
  ttl                 = 300
  records             = ["${azurerm_public_ip.current.ip_address}"]

  tags = "${var.metadata_labels}"
}
