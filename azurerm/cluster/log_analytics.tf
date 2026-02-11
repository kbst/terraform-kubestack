resource "azurerm_log_analytics_workspace" "current" {
  count               = local.enable_log_analytics == true ? 1 : 0
  name                = module.cluster_metadata.name
  location            = data.azurerm_resource_group.current.location
  resource_group_name = data.azurerm_resource_group.current.name
  sku                 = "PerGB2018"

  tags = merge(module.cluster_metadata.labels, local.additional_metadata_labels)
}

resource "azurerm_log_analytics_solution" "current" {
  count                 = local.enable_log_analytics == true ? 1 : 0
  solution_name         = "ContainerInsights"
  location              = data.azurerm_resource_group.current.location
  resource_group_name   = data.azurerm_resource_group.current.name
  workspace_resource_id = azurerm_log_analytics_workspace.current[0].id
  workspace_name        = azurerm_log_analytics_workspace.current[0].name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}
