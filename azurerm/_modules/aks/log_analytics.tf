resource "azurerm_log_analytics_workspace" "current" {
  name                = "${var.metadata_name}"
  location            = "${data.azurerm_resource_group.current.location}"
  resource_group_name = "${data.azurerm_resource_group.current.name}"
  sku                 = "PerGB2018"

  tags = "${var.metadata_labels}"
}

resource "azurerm_log_analytics_solution" "current" {
  solution_name         = "ContainerInsights"
  location              = "${data.azurerm_resource_group.current.location}"
  resource_group_name   = "${data.azurerm_resource_group.current.name}"
  workspace_resource_id = "${azurerm_log_analytics_workspace.current.id}"
  workspace_name        = "${azurerm_log_analytics_workspace.current.name}"

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}
