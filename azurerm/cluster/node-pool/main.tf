locals {
  use_spot = local.cfg["use_spot"] != null ? local.cfg["use_spot"] : false
  priority = local.use_spot ? "Spot" : local.cfg["priority"] != null ? local.cfg["priority"] : "Regular"

  user_node_labels = local.cfg["node_labels"] != null ? local.cfg["node_labels"] : {}
  user_node_taints = local.cfg["node_taints"] != null ? local.cfg["node_taints"] : []

  spot_taints = [
    "kubernetes.azure.com/scalesetpriority=spot:NoSchedule",
  ]
  spot_labels = { "kubernetes.azure.com/scalesetpriority" = "spot" }

  labels      = merge(local.use_spot ? local.spot_labels : {}, local.user_node_labels)
  taints      = compact(concat(local.use_spot ? local.spot_taints : [], local.user_node_taints))
  node_labels = length(local.labels) == 0 ? null : local.labels
  node_taints = length(local.taints) == 0 ? null : local.taints
}

module "node_pool" {
  source = "../../_modules/aks/node_pool"

  cluster_name   = var.cluster_name
  resource_group = var.resource_group

  node_pool_name = local.cfg["node_pool_name"]

  availability_zones = local.cfg["availability_zones"]

  vm_size         = local.cfg["vm_size"] != null ? local.cfg["vm_size"] : "Standard_B2s"
  max_pods        = local.cfg["max_pods"] != null ? local.cfg["max_pods"] : 110
  os_disk_type    = local.cfg["os_disk_type"] != null ? local.cfg["os_disk_type"] : "Managed"
  os_disk_size_gb = local.cfg["os_disk_size_gb"]

  enable_auto_scaling = local.cfg["enable_auto_scaling"] != null ? local.cfg["enable_auto_scaling"] : true
  min_count           = local.cfg["min_count"] != null ? local.cfg["min_count"] : 1
  max_count           = local.cfg["max_count"] != null ? local.cfg["max_count"] : 1
  node_count          = local.cfg["node_count"] != null ? local.cfg["node_count"] : 1

  priority        = local.cfg["use_spot"] == true ? "Spot" : local.cfg["priority"] != null ? local.cfg["priority"] : "Regular"
  eviction_policy = local.cfg["eviction_policy"]
  max_spot_price  = local.cfg["max_spot_price"]

  node_labels = merge(local.cfg["use_spot"] == true ? { "kubernetes.azure.com/scalesetpriority" = "spot" } : {}, local.cfg["node_labels"])
  node_taints = compact(concat(local.cfg["use_spot"] == true ? ["kubernetes.azure.com/scalesetpriority=spot:NoSchedule"] : [], local.cfg["node_taints"]))
}
