module "configuration" {
  source = "../../../common/configuration"

  configuration = var.configuration
  base_key      = var.configuration_base_key
}

locals {
  cfg = module.configuration.merged[terraform.workspace]

  node_pool_name          = local.cfg["node_pool_name"]
  vm_size                 = local.cfg["vm_size"] != null ? local.cfg["vm_size"] : "Standard_B2s"
  max_pods                = local.cfg["max_pods"] != null ? local.cfg["max_pods"] : "110"
  os_disk_type            = local.cfg["os_disk_type"] != null ? local.cfg["os_disk_type"] : "Managed"
  os_disk_size_gb         = local.cfg["os_disk_size_gb"]
  availability_zones_list = local.cfg["availability_zones"] != null ? local.cfg["availability_zones"] : []
  availability_zones      = length(local.availability_zones_list) == 0 ? null : local.availability_zones_list

  enable_auto_scaling = local.cfg["enable_auto_scaling"] != null ? local.cfg["enable_auto_scaling"] : true
  max_count_string    = local.cfg["max_count"] != null ? local.cfg["max_count"] : "1"
  min_count_string    = local.cfg["min_count"] != null ? local.cfg["min_count"] : "1"
  max_count           = local.enable_auto_scaling ? local.max_count_string : null
  min_count           = local.enable_auto_scaling ? local.min_count_string : null
  node_count          = local.cfg["node_count"] != null ? local.cfg["node_count"] : "1"

  use_spot             = local.cfg["use_spot"] != null ? local.cfg["use_spot"] : false
  priority             = local.use_spot ? "Spot" : "Regular"
  eviction_policy      = local.use_spot ? local.cfg["eviction_policy"] : null
  max_spot_price_value = local.cfg["max_spot_price"] != null ? local.cfg["max_spot_price"] : "-1"
  max_spot_price       = local.use_spot ? local.max_spot_price_value : null

  user_node_labels = local.cfg["node_labels"] != null ? local.cfg["node_labels"] : {}
  user_node_taints = local.cfg["node_taints"] != null ? local.cfg["node_taints"] : []
  spot_taints = [
    "kubernetes.azure.com/scalesetpriority=spot:NoSchedule",
  ]
  spot_labels = { "kubernetes.azure.com/scalesetpriority" = "spot" }

  taints      = compact(concat(local.use_spot ? local.spot_taints : [], local.user_node_taints))
  labels      = merge(local.use_spot ? local.spot_labels : {}, local.user_node_labels)
  node_labels = length(local.labels) == 0 ? null : local.labels
  node_taints = length(local.taints) == 0 ? null : local.taints
}
