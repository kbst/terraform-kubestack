resource "azurerm_public_ip" "current" {
  count = try(coalesce(local.cfg.disable_default_ingress, null), false) ? 0 : 1

  name                = module.cluster_metadata.name
  location            = azurerm_kubernetes_cluster.current.location
  resource_group_name = azurerm_kubernetes_cluster.current.node_resource_group
  allocation_method   = "Static"
  sku                 = "Standard"

  zones = try(coalesce(local.cfg.default_ingress_ip_zones, null), [])

  tags = merge(module.cluster_metadata.labels, try(local.cfg.additional_metadata_labels, {}))

  depends_on = [azurerm_kubernetes_cluster.current]
}

resource "azurerm_dns_zone" "current" {
  count = try(coalesce(local.cfg.disable_default_ingress, null), false) ? 0 : 1

  name                = module.cluster_metadata.fqdn
  resource_group_name = data.azurerm_resource_group.current.name

  tags = merge(module.cluster_metadata.labels, try(local.cfg.additional_metadata_labels, {}))
}

resource "azurerm_dns_a_record" "host" {
  count = try(coalesce(local.cfg.disable_default_ingress, null), false) ? 0 : 1

  name                = "@"
  zone_name           = azurerm_dns_zone.current[0].name
  resource_group_name = data.azurerm_resource_group.current.name
  ttl                 = 300
  records             = [azurerm_public_ip.current[0].ip_address]

  tags = merge(module.cluster_metadata.labels, try(local.cfg.additional_metadata_labels, {}))
}

resource "azurerm_dns_a_record" "wildcard" {
  count = try(coalesce(local.cfg.disable_default_ingress, null), false) ? 0 : 1

  name                = "*"
  zone_name           = azurerm_dns_zone.current[0].name
  resource_group_name = data.azurerm_resource_group.current.name
  ttl                 = 300
  records             = [azurerm_public_ip.current[0].ip_address]

  tags = merge(module.cluster_metadata.labels, try(local.cfg.additional_metadata_labels, {}))
}
