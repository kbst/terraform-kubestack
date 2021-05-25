resource "azurerm_public_ip" "current" {
  count = var.disable_default_ingress ? 0 : 1

  name                = var.metadata_name
  location            = azurerm_kubernetes_cluster.current.location
  resource_group_name = azurerm_kubernetes_cluster.current.node_resource_group
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.metadata_labels

  depends_on = [azurerm_kubernetes_cluster.current]
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
