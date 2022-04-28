data "azurerm_resource_group" "current" {
  name = var.resource_group
}

resource "azurerm_kubernetes_cluster" "current" {
  name                      = var.metadata_name
  location                  = data.azurerm_resource_group.current.location
  resource_group_name       = data.azurerm_resource_group.current.name
  dns_prefix                = var.dns_prefix
  sku_tier                  = var.sku_tier
  kubernetes_version        = var.kubernetes_version
  automatic_channel_upgrade = var.automatic_channel_upgrade

  role_based_access_control_enabled = true

  default_node_pool {
    name = var.default_node_pool_name
    type = var.default_node_pool_type

    enable_auto_scaling = var.default_node_pool_enable_auto_scaling

    # set min and max count only if autoscaling is _enabled_
    min_count = var.default_node_pool_enable_auto_scaling ? var.default_node_pool_min_count : null
    max_count = var.default_node_pool_enable_auto_scaling ? var.default_node_pool_max_count : null

    # set node count only if auto scaling is _disabled_
    node_count = var.default_node_pool_enable_auto_scaling ? null : var.default_node_pool_node_count

    vm_size         = var.default_node_pool_vm_size
    os_disk_size_gb = var.default_node_pool_os_disk_size_gb

    vnet_subnet_id = var.network_plugin == "azure" ? azurerm_subnet.current[0].id : null
    max_pods       = var.max_pods

    only_critical_addons_enabled = var.default_node_pool_only_critical_addons

    zones = var.availability_zones
  }

  network_profile {
    network_plugin = var.network_plugin
    network_policy = var.network_policy

    docker_bridge_cidr = "172.17.0.1/16"
    service_cidr       = var.service_cidr
    dns_service_ip     = var.dns_service_ip
    pod_cidr           = var.network_plugin == "azure" ? null : var.pod_cidr
  }

  dynamic "identity" {
    for_each = var.disable_managed_identities == true ? toset([]) : toset([1])

    content {
      type = var.user_assigned_identity_id == null ? "SystemAssigned" : "UserAssigned"

      identity_ids = var.user_assigned_identity_id == null ? null : [var.user_assigned_identity_id]
    }
  }

  dynamic "service_principal" {
    for_each = var.disable_managed_identities == true ? toset([1]) : toset([])

    content {
      client_id     = azuread_application.current[0].application_id
      client_secret = azuread_service_principal_password.current[0].value
    }
  }

  azure_policy_enabled = var.enable_azure_policy_agent

  dynamic "oms_agent" {
    for_each = var.enable_log_analytics ? toset([1]) : toset([])

    content {
      log_analytics_workspace_id = var.enable_log_analytics ? azurerm_log_analytics_workspace.current[0].id : null
    }
  }

  tags = var.metadata_labels
}
