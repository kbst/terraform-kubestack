module "configuration" {
  source        = "../../../common/configuration"
  configuration = var.configuration
  base_key      = var.configuration_base_key
}

locals {
  cfg = module.configuration.merged[terraform.workspace]

  taint_tags = [
    for t in try(coalesce(local.cfg.node_taints, null), []) :
    "taint=${t.key}=${t.value}:${t.effect}"
  ]

  all_tags = concat(
    var.cluster_metadata.tags,
    try(coalesce(local.cfg.tags, null), []),
    local.taint_tags
  )
}

resource "scaleway_k8s_pool" "current" {
  for_each = toset(local.cfg.zones)

  cluster_id = var.cluster.id
  name       = "${local.cfg.name}-${each.value}"
  region     = var.cluster.region
  zone       = each.value

  node_type = try(coalesce(local.cfg.node_type, null), "GP1-XS")
  size      = try(coalesce(local.cfg.size, null), 1)
  min_size  = try(coalesce(local.cfg.min_size, null), 1)
  max_size  = try(coalesce(local.cfg.max_size, null), 2)

  autoscaling = try(coalesce(local.cfg.autoscaling, null), true)
  autohealing = try(coalesce(local.cfg.autohealing, null), true)

  container_runtime      = try(coalesce(local.cfg.container_runtime, null), "containerd")
  root_volume_type       = local.cfg.root_volume_type
  root_volume_size_in_gb = local.cfg.root_volume_size_in_gb

  public_ip_disabled = try(coalesce(local.cfg.public_ip_disabled, null), false)

  wait_for_pool_ready = try(coalesce(local.cfg.wait_for_pool_ready, null), true)

  kubelet_args = try(coalesce(local.cfg.kubelet_args, null), {})

  tags = local.all_tags

  dynamic "upgrade_policy" {
    for_each = local.cfg.upgrade_policy != null ? [1] : []

    content {
      max_surge       = try(coalesce(local.cfg.upgrade_policy.max_surge, null), 0)
      max_unavailable = try(coalesce(local.cfg.upgrade_policy.max_unavailable, null), 1)
    }
  }

  # When autoscaling acts, the size gets changed by Scaleway, but it should not
  # be forced back to match the configuration on the next plan.
  lifecycle {
    ignore_changes = [size]
  }
}
