resource "azurerm_virtual_network" "current" {
  count = try(coalesce(local.cfg.network_plugin, null), "kubenet") == "azure" ? 1 : 0

  name                = try(coalesce(local.cfg.legacy_vnet_name, null), false) ? "vnet-aks-${terraform.workspace}-cluster" : module.cluster_metadata.name
  address_space       = try(coalesce(local.cfg.vnet_address_space, null), ["10.0.0.0/8"])
  resource_group_name = data.azurerm_resource_group.current.name
  location            = data.azurerm_resource_group.current.location
}

resource "azurerm_subnet" "current" {
  count = try(coalesce(local.cfg.network_plugin, null), "kubenet") == "azure" ? 1 : 0

  name                 = try(coalesce(local.cfg.legacy_vnet_name, null), false) ? "aks-node-subnet" : "${module.cluster_metadata.name}-${try(coalesce(local.cfg.default_node_pool.name, null), "default")}-node-pool"
  address_prefixes     = try(coalesce(local.cfg.subnet_address_prefixes, null), ["10.1.0.0/16"])
  resource_group_name  = data.azurerm_resource_group.current.name
  virtual_network_name = azurerm_virtual_network.current[0].name

  service_endpoints = length(try(coalesce(local.cfg.subnet_service_endpoints, null), [])) > 0 ? try(coalesce(local.cfg.subnet_service_endpoints, null), []) : null
}
