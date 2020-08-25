resource "azurerm_public_ip" "current" {
  count = var.disable_default_ingress ? 0 : 1

  name                = var.metadata_name
  location            = azurerm_kubernetes_cluster.current.location
  resource_group_name = azurerm_kubernetes_cluster.current.node_resource_group
  allocation_method   = "Static"

  tags = var.metadata_labels

  depends_on = [azurerm_kubernetes_cluster.current]
}

resource "kubernetes_service" "current" {
  count = var.disable_default_ingress ? 0 : 1

  provider = kubernetes.aks

  metadata {
    name      = "ingress-kbst-default"
    namespace = "ingress-kbst-default"
  }

  spec {
    type             = "LoadBalancer"
    load_balancer_ip = azurerm_public_ip.current[0].ip_address

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

resource "azurerm_dns_zone" "current" {
  count = var.disable_default_ingress ? 0 : 1

  name                = var.metadata_fqdn
  resource_group_name = data.azurerm_resource_group.current.name

  tags = var.metadata_labels
}

resource "azurerm_dns_a_record" "host" {
  count = var.disable_default_ingress ? 0 : 1

  name                = "@"
  zone_name           = azurerm_dns_zone.current[0].name
  resource_group_name = data.azurerm_resource_group.current.name
  ttl                 = 300
  records             = [azurerm_public_ip.current[0].ip_address]

  tags = var.metadata_labels
}

resource "azurerm_dns_a_record" "wildcard" {
  count = var.disable_default_ingress ? 0 : 1

  name                = "*"
  zone_name           = azurerm_dns_zone.current[0].name
  resource_group_name = data.azurerm_resource_group.current.name
  ttl                 = 300
  records             = [azurerm_public_ip.current[0].ip_address]

  tags = var.metadata_labels
}
