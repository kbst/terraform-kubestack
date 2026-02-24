module "configuration" {
  source        = "../../../common/configuration"
  configuration = var.configuration
  base_key      = var.configuration_base_key
}

locals {
  cfg = module.configuration.merged[terraform.workspace]

  vnet_subnets = compact(var.cluster.default_node_pool.*.vnet_subnet_id)

  # Conditional logic for auto_scaling
  effective_max_count = try(coalesce(local.cfg.enable_auto_scaling, null), true) == true ? local.cfg.max_count : null
  effective_min_count = try(coalesce(local.cfg.enable_auto_scaling, null), true) == true ? local.cfg.min_count : null

  # Conditional logic for spot instances
  effective_priority        = try(coalesce(local.cfg.use_spot, null), false) == true ? "Spot" : "Regular"
  effective_eviction_policy = try(coalesce(local.cfg.use_spot, null), false) == true ? local.cfg.eviction_policy : null
  effective_max_spot_price  = try(coalesce(local.cfg.use_spot, null), false) == true ? try(coalesce(local.cfg.max_spot_price, null), -1) : null

  # Spot instance labels and taints
  spot_label  = try(coalesce(local.cfg.use_spot, null), false) == true ? { "kubernetes.azure.com/scalesetpriority" = "spot" } : {}
  spot_taints = try(coalesce(local.cfg.use_spot, null), false) == true ? ["kubernetes.azure.com/scalesetpriority=spot:NoSchedule"] : []

  # Merge labels and taints
  node_labels_merged = merge(local.spot_label, try(coalesce(local.cfg.node_labels, null), {}))
  node_taints_merged = compact(concat(local.spot_taints, try(coalesce(local.cfg.node_taints, null), [])))
}

resource "azurerm_kubernetes_cluster_node_pool" "current" {
  name                  = local.cfg.node_pool_name
  kubernetes_cluster_id = var.cluster.id
  auto_scaling_enabled  = try(coalesce(local.cfg.enable_auto_scaling, null), true)
  max_count             = local.effective_max_count
  min_count             = local.effective_min_count
  node_count            = try(coalesce(local.cfg.node_count, null), 1)
  vm_size               = try(coalesce(local.cfg.vm_size, null), "Standard_B2s")
  node_labels           = local.node_labels_merged
  node_taints           = local.node_taints_merged
  zones                 = local.cfg.availability_zones
  max_pods              = try(coalesce(local.cfg.max_pods, null), 110)
  os_disk_type          = try(coalesce(local.cfg.os_disk_type, null), "Managed")
  os_disk_size_gb       = local.cfg.os_disk_size_gb
  priority              = local.effective_priority
  eviction_policy       = local.effective_eviction_policy
  spot_max_price        = local.effective_max_spot_price

  upgrade_settings {
    max_surge                     = try(coalesce(try(local.cfg.upgrade_settings, null).max_surge, null), "10%")
    drain_timeout_in_minutes      = try(coalesce(try(local.cfg.upgrade_settings, null).drain_timeout_in_minutes, null), 0)
    node_soak_duration_in_minutes = try(coalesce(try(local.cfg.upgrade_settings, null).node_soak_duration_in_minutes, null), 0)
  }

  # The cluster's agent_pool_profile may contain empty strings for vnet_subnet_id
  # in some configurations. In that case we rely on the defaults.
  vnet_subnet_id = length(local.vnet_subnets) == 0 ? null : coalesce(tolist(local.vnet_subnets)...)

  # When autoscaling acts, the node_count gets changed, but it should not be
  # forced to match the config
  lifecycle {
    ignore_changes = [node_count]
  }
}
