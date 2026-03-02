module "configuration" {
  source        = "../../common/configuration"
  configuration = var.configuration
  base_key      = var.configuration_base_key
}

locals {
  cfg = module.configuration.merged[terraform.workspace]
}

module "cluster_metadata" {
  source = "../../common/metadata"

  name_prefix = local.cfg.name_prefix
  base_domain = local.cfg.base_domain

  provider_name   = "azure"
  provider_region = data.azurerm_resource_group.current.location # references cluster.tf data source

  # Azure does not allow / character in labels
  label_namespace = "kubestack.com-"
}

data "azurerm_resource_group" "current" {
  name = local.cfg.resource_group
}

resource "azurerm_kubernetes_cluster" "current" {
  name                = module.cluster_metadata.name
  location            = data.azurerm_resource_group.current.location
  resource_group_name = data.azurerm_resource_group.current.name

  lifecycle {
    precondition {
      condition     = local.cfg.resource_group != null
      error_message = "missing required configuration attribute: resource_group"
    }

    precondition {
      condition     = local.cfg.availability_zones != null
      error_message = "missing required configuration attribute: availability_zones"
    }

    precondition {
      condition     = try(local.cfg.default_node_pool.vm_size, null) != null
      error_message = "missing required configuration attribute: default_node_pool.vm_size"
    }

    precondition {
      condition     = try(coalesce(local.cfg.default_node_pool.enable_auto_scaling, null), true) == false || try(local.cfg.default_node_pool.min_count, null) != null
      error_message = "missing required configuration attribute: default_node_pool.min_count"
    }

    precondition {
      condition     = try(coalesce(local.cfg.default_node_pool.enable_auto_scaling, null), true) == false || try(local.cfg.default_node_pool.max_count, null) != null
      error_message = "missing required configuration attribute: default_node_pool.max_count"
    }
  }

  dns_prefix                = try(coalesce(local.cfg.dns_prefix, null), "api")
  sku_tier                  = try(coalesce(local.cfg.sku_tier, null), "Free")
  kubernetes_version        = local.cfg.kubernetes_version
  automatic_upgrade_channel = local.cfg.automatic_channel_upgrade

  role_based_access_control_enabled = true

  default_node_pool {
    name = try(coalesce(local.cfg.default_node_pool.name, null), "default")
    type = try(coalesce(local.cfg.default_node_pool.type, null), "VirtualMachineScaleSets")

    auto_scaling_enabled = try(coalesce(local.cfg.default_node_pool.enable_auto_scaling, null), true)

    # set min and max count only if autoscaling is _enabled_
    min_count = try(coalesce(local.cfg.default_node_pool.enable_auto_scaling, null), true) ? local.cfg.default_node_pool.min_count : null
    max_count = try(coalesce(local.cfg.default_node_pool.enable_auto_scaling, null), true) ? local.cfg.default_node_pool.max_count : null

    # set node count only if auto scaling is _disabled_
    node_count = try(coalesce(local.cfg.default_node_pool.enable_auto_scaling, null), true) ? null : try(coalesce(local.cfg.default_node_pool.node_count, null), 1)

    vm_size         = local.cfg.default_node_pool.vm_size
    os_disk_size_gb = try(coalesce(local.cfg.default_node_pool.os_disk_size_gb, null), 30)

    vnet_subnet_id = try(coalesce(local.cfg.network_plugin, null), "kubenet") == "azure" ? azurerm_subnet.current[0].id : null
    max_pods       = local.cfg.max_pods

    only_critical_addons_enabled = try(coalesce(local.cfg.default_node_pool.only_critical_addons, null), false)

    zones = local.cfg.availability_zones

    upgrade_settings {
      max_surge                     = try(coalesce(try(local.cfg.default_node_pool.upgrade_settings, null).max_surge, null), "10%")
      drain_timeout_in_minutes      = try(coalesce(try(local.cfg.default_node_pool.upgrade_settings, null).drain_timeout_in_minutes, null), 0)
      node_soak_duration_in_minutes = try(coalesce(try(local.cfg.default_node_pool.upgrade_settings, null).node_soak_duration_in_minutes, null), 0)
    }
  }

  network_profile {
    network_plugin = try(coalesce(local.cfg.network_plugin, null), "kubenet")
    network_policy = try(coalesce(local.cfg.network_policy, null), "calico")

    service_cidr   = try(coalesce(local.cfg.service_cidr, null), "10.0.0.0/16")
    dns_service_ip = try(coalesce(local.cfg.dns_service_ip, null), "10.0.0.10")
    pod_cidr       = try(coalesce(local.cfg.network_plugin, null), "kubenet") == "azure" ? null : try(coalesce(local.cfg.pod_cidr, null), "10.244.0.0/16")
  }

  dynamic "identity" {
    for_each = try(coalesce(local.cfg.disable_managed_identities, null), false) == true ? toset([]) : toset([1])

    content {
      type = local.cfg.user_assigned_identity_id == null ? "SystemAssigned" : "UserAssigned"

      identity_ids = local.cfg.user_assigned_identity_id == null ? null : [local.cfg.user_assigned_identity_id]
    }
  }

  dynamic "service_principal" {
    for_each = try(coalesce(local.cfg.disable_managed_identities, null), false) == true ? toset([1]) : toset([])

    content {
      client_id     = azuread_application.current[0].application_id
      client_secret = azuread_service_principal_password.current[0].value
    }
  }

  azure_policy_enabled = try(coalesce(local.cfg.enable_azure_policy_agent, null), false)

  dynamic "oms_agent" {
    for_each = try(coalesce(local.cfg.enable_log_analytics, null), true) ? toset([1]) : toset([])

    content {
      log_analytics_workspace_id = azurerm_log_analytics_workspace.current[0].id
    }
  }

  dynamic "workload_autoscaler_profile" {
    for_each = try(coalesce(local.cfg.keda_enabled, null), false) || try(coalesce(local.cfg.vertical_pod_autoscaler_enabled, null), false) ? toset([1]) : toset([])

    content {
      keda_enabled                    = try(coalesce(local.cfg.keda_enabled, null), false)
      vertical_pod_autoscaler_enabled = try(coalesce(local.cfg.vertical_pod_autoscaler_enabled, null), false)
    }
  }

  tags = merge(module.cluster_metadata.labels, try(local.cfg.additional_metadata_labels, {}))
}
