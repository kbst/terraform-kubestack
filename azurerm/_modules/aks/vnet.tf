
resource "azurerm_virtual_network" "current" {
  count = var.network_plugin == "azure" ? 1 : 0

  name                = var.legacy_vnet_name ? "vnet-aks-${terraform.workspace}-cluster" : var.metadata_name
  address_space       = var.vnet_address_space
  resource_group_name = data.azurerm_resource_group.current.name
  location            = data.azurerm_resource_group.current.location
}

resource "azurerm_subnet" "current" {
  count = var.network_plugin == "azure" ? 1 : 0

  name                 = var.legacy_vnet_name ? "aks-node-subnet" : "${var.metadata_name}-${var.default_node_pool_name}-node-pool"
  address_prefixes     = var.subnet_address_prefixes
  resource_group_name  = data.azurerm_resource_group.current.name
  virtual_network_name = azurerm_virtual_network.current[0].name

  service_endpoints = var.subnet_service_endpoints
}
