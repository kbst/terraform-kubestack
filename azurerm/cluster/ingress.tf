resource "azurerm_public_ip" "current" {
  count = local.disable_default_ingress ? 0 : 1

  name                = module.cluster_metadata.name
  location            = azurerm_kubernetes_cluster.current.location
  resource_group_name = azurerm_kubernetes_cluster.current.node_resource_group
  allocation_method   = "Static"
  sku                 = "Standard"

  zones = local.default_ingress_ip_zones

  tags = merge(module.cluster_metadata.labels, local.additional_metadata_labels)

  depends_on = [azurerm_kubernetes_cluster.current]
}

resource "azurerm_dns_zone" "current" {
  count = local.disable_default_ingress ? 0 : 1

  name                = module.cluster_metadata.fqdn
  resource_group_name = data.azurerm_resource_group.current.name

  tags = merge(module.cluster_metadata.labels, local.additional_metadata_labels)
}

resource "azurerm_dns_a_record" "host" {
  count = local.disable_default_ingress ? 0 : 1

  name                = "@"
  zone_name           = azurerm_dns_zone.current[0].name
  resource_group_name = data.azurerm_resource_group.current.name
  ttl                 = 300
  records             = [azurerm_public_ip.current[0].ip_address]

  tags = merge(module.cluster_metadata.labels, local.additional_metadata_labels)
}

resource "azurerm_dns_a_record" "wildcard" {
  count = local.disable_default_ingress ? 0 : 1

  name                = "*"
  zone_name           = azurerm_dns_zone.current[0].name
  resource_group_name = data.azurerm_resource_group.current.name
  ttl                 = 300
  records             = [azurerm_public_ip.current[0].ip_address]

  tags = merge(module.cluster_metadata.labels, local.additional_metadata_labels)
}
