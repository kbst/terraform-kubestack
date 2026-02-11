data "azurerm_resource_group" "current" {
  name = local.resource_group
}

module "cluster_metadata" {
  source = "../../common/metadata"

  name_prefix = local.name_prefix
  base_domain = local.base_domain

  provider_name   = "azure"
  provider_region = data.azurerm_resource_group.current.location

  # Azure does not allow / character in labels
  label_namespace = "kubestack.com-"
}

resource "azurerm_kubernetes_cluster" "current" {
  name                      = module.cluster_metadata.name
  location                  = data.azurerm_resource_group.current.location
  resource_group_name       = data.azurerm_resource_group.current.name
  dns_prefix                = local.dns_prefix
  sku_tier                  = local.sku_tier
  kubernetes_version        = local.kubernetes_version
  automatic_upgrade_channel = local.automatic_channel_upgrade

  role_based_access_control_enabled = true

  default_node_pool {
    name = local.default_node_pool_name
    type = local.default_node_pool_type

    auto_scaling_enabled = local.default_node_pool_enable_auto_scaling

    # set min and max count only if autoscaling is _enabled_
    min_count = local.default_node_pool_enable_auto_scaling ? local.default_node_pool_min_count : null
    max_count = local.default_node_pool_enable_auto_scaling ? local.default_node_pool_max_count : null

    # set node count only if auto scaling is _disabled_
    node_count = local.default_node_pool_enable_auto_scaling ? null : local.default_node_pool_node_count

    vm_size         = local.default_node_pool_vm_size
    os_disk_size_gb = local.default_node_pool_os_disk_size_gb

    vnet_subnet_id = local.network_plugin == "azure" ? azurerm_subnet.current[0].id : null
    max_pods       = local.max_pods

    only_critical_addons_enabled = local.default_node_pool_only_critical_addons

    zones = local.availability_zones

    upgrade_settings {
      max_surge                     = local.upgade_settings_max_surge
      drain_timeout_in_minutes      = local.upgade_settings_drain_timeout_in_minutes
      node_soak_duration_in_minutes = local.upgade_settings_node_soak_duration_in_minutes
    }
  }

  network_profile {
    network_plugin = local.network_plugin
    network_policy = local.network_policy

    service_cidr   = local.service_cidr
    dns_service_ip = local.dns_service_ip
    pod_cidr       = local.network_plugin == "azure" ? null : local.pod_cidr
  }

  dynamic "identity" {
    for_each = local.disable_managed_identities == true ? toset([]) : toset([1])

    content {
      type = local.user_assigned_identity_id == null ? "SystemAssigned" : "UserAssigned"

      identity_ids = local.user_assigned_identity_id == null ? null : [local.user_assigned_identity_id]
    }
  }

  dynamic "service_principal" {
    for_each = local.disable_managed_identities == true ? toset([1]) : toset([])

    content {
      client_id     = azuread_application.current[0].application_id
      client_secret = azuread_service_principal_password.current[0].value
    }
  }

  azure_policy_enabled = local.enable_azure_policy_agent

  dynamic "oms_agent" {
    for_each = local.enable_log_analytics ? toset([1]) : toset([])

    content {
      log_analytics_workspace_id = local.enable_log_analytics ? azurerm_log_analytics_workspace.current[0].id : null
    }
  }

  dynamic "workload_autoscaler_profile" {
    for_each = local.keda_enabled || local.vertical_pod_autoscaler_enabled ? toset([1]) : toset([])

    content {
      keda_enabled                    = local.keda_enabled
      vertical_pod_autoscaler_enabled = local.vertical_pod_autoscaler_enabled
    }
  }

  tags = merge(module.cluster_metadata.labels, local.additional_metadata_labels)
}
