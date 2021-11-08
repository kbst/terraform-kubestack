module "node_pool" {
  source = "../../_modules/aks/node_pool"

  cluster_name   = var.cluster_name
  resource_group = var.resource_group

  node_pool_name      = local.node_pool_name
  enable_auto_scaling = local.enable_auto_scaling
  max_count           = local.max_count
  min_count           = local.min_count
  node_count          = local.node_count
  vm_size             = local.vm_size
  eviction_policy     = local.eviction_policy
  priority            = local.priority
  max_spot_price      = local.max_spot_price
  node_labels         = local.node_labels
  node_taints         = local.node_taints
  availability_zones  = local.availability_zones
  os_disk_type        = local.os_disk_type
  os_disk_size_gb     = local.os_disk_size_gb
  max_pods            = local.max_pods
}
