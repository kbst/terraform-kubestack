
resource "azurerm_virtual_network" "current" {
  count = var.network_plugin == "azure" ? 1 : 0

  name                = "vnet-aks-${terraform.workspace}-cluster"
  address_space       = var.vnet_address_space
  resource_group_name = data.azurerm_resource_group.current.name
  location            = data.azurerm_resource_group.current.location
}

resource "azurerm_subnet" "current" {
  count = var.network_plugin == "azure" ? 1 : 0

  name                 = "aks-node-subnet"
  address_prefixes     = var.subnet_address_prefixes
  resource_group_name  = data.azurerm_resource_group.current.name
  virtual_network_name = azurerm_virtual_network.current[0].name

  service_endpoints = length(var.subnet_service_endpoints) > 0 ? var.subnet_service_endpoints : null
}
