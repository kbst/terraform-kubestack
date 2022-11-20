data "azurerm_kubernetes_cluster" "current" {
  name                = var.cluster_name
  resource_group_name = var.resource_group
}

locals {
  vnet_subnets = compact(data.azurerm_kubernetes_cluster.current.agent_pool_profile[*].vnet_subnet_id)
}

resource "azurerm_kubernetes_cluster_node_pool" "current" {
  name                  = var.node_pool_name
  kubernetes_cluster_id = data.azurerm_kubernetes_cluster.current.id
  enable_auto_scaling   = var.enable_auto_scaling
  max_count             = var.max_count
  min_count             = var.min_count
  node_count            = var.node_count
  vm_size               = var.vm_size
  node_labels           = var.node_labels
  node_taints           = var.node_taints
  zones                 = var.availability_zones
  max_pods              = var.max_pods
  os_disk_type          = var.os_disk_type
  os_disk_size_gb       = var.os_disk_size_gb
  priority              = var.priority
  eviction_policy       = var.eviction_policy
  spot_max_price        = var.max_spot_price

  # The data source returned agent_pool_profiles in some configurations contain
  # empty strings in vnet_subnet_id. In that case we rely on the defaults
  vnet_subnet_id = length(local.vnet_subnets) == 0 ? null : coalesce(tolist(local.vnet_subnets)...)

  # When autoscaling acts, the node_count gets changed, but it should not be
  # forced to match the config
  lifecycle {
    ignore_changes = [node_count]
  }
}

