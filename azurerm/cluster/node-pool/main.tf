data "azurerm_kubernetes_cluster" "current" {
  name                = var.cluster_name
  resource_group_name = var.resource_group
}

data "azurerm_client_config" "current" {}

locals {
  vnet_subnets = compact(data.azurerm_kubernetes_cluster.current.agent_pool_profile[*].vnet_subnet_id)
}

resource "azurerm_kubernetes_cluster_node_pool" "current" {
  name                  = local.node_pool_name
  kubernetes_cluster_id = data.azurerm_kubernetes_cluster.current.id
  auto_scaling_enabled  = local.enable_auto_scaling
  max_count             = local.max_count
  min_count             = local.min_count
  node_count            = local.node_count
  vm_size               = local.vm_size
  node_labels           = local.node_labels
  node_taints           = local.node_taints
  zones                 = local.availability_zones
  max_pods              = local.max_pods
  os_disk_type          = local.os_disk_type
  os_disk_size_gb       = local.os_disk_size_gb
  priority              = local.priority
  eviction_policy       = local.eviction_policy
  spot_max_price        = local.max_spot_price

  # The data source returned agent_pool_profiles in some configurations contain
  # empty strings in vnet_subnet_id. In that case we rely on the defaults
  vnet_subnet_id = length(local.vnet_subnets) == 0 ? null : coalesce(tolist(local.vnet_subnets)...)

  # When autoscaling acts, the node_count gets changed, but it should not be
  # forced to match the config
  lifecycle {
    ignore_changes = [node_count]
  }
}
