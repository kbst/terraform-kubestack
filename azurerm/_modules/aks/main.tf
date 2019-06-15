data "azurerm_resource_group" "current" {
  name = var.resource_group
}

resource "azurerm_kubernetes_cluster" "current" {
  name                = var.metadata_name
  location            = data.azurerm_resource_group.current.location
  resource_group_name = data.azurerm_resource_group.current.name
  dns_prefix          = var.dns_prefix

  role_based_access_control {
    enabled = true
  }

  agent_pool_profile {
    name            = var.agent_pool_profile_name
    count           = var.agent_pool_profile_count
    vm_size         = var.agent_pool_profile_vm_size
    os_type         = var.agent_pool_profile_os_type
    os_disk_size_gb = var.agent_pool_profile_os_disk_size_gb
  }

  service_principal {
    client_id     = azuread_application.current.application_id
    client_secret = azuread_service_principal_password.current.value
  }

  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.current.id
    }
  }

  tags = var.metadata_labels
}

