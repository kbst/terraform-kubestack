
resource "azurerm_virtual_network" "current" {
  count = local.network_plugin == "azure" ? 1 : 0

  name                = local.legacy_vnet_name ? "vnet-aks-${terraform.workspace}-cluster" : module.cluster_metadata.name
  address_space       = local.vnet_address_space
  resource_group_name = data.azurerm_resource_group.current.name
  location            = data.azurerm_resource_group.current.location
}

resource "azurerm_subnet" "current" {
  count = local.network_plugin == "azure" ? 1 : 0

  name                 = local.legacy_vnet_name ? "aks-node-subnet" : "${module.cluster_metadata.name}-${local.default_node_pool_name}-node-pool"
  address_prefixes     = local.subnet_address_prefixes
  resource_group_name  = data.azurerm_resource_group.current.name
  virtual_network_name = azurerm_virtual_network.current[0].name

  service_endpoints = length(local.subnet_service_endpoints) > 0 ? local.subnet_service_endpoints : null
}
