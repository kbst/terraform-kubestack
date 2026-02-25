module "node_pool" {
  source = "./node-pool"

  cluster          = scaleway_k8s_cluster.current
  cluster_metadata = module.cluster_metadata

  configuration = {
    (terraform.workspace) = {
      name  = "default"
      zones = local.cfg.default_node_pool.zones

      node_type   = try(coalesce(local.cfg.default_node_pool.node_type, null), "GP1-XS")
      size        = try(coalesce(local.cfg.default_node_pool.size, null), 1)
      min_size    = try(coalesce(local.cfg.default_node_pool.min_size, null), 1)
      max_size    = try(coalesce(local.cfg.default_node_pool.max_size, null), 2)
      autoscaling = try(coalesce(local.cfg.default_node_pool.autoscaling, null), true)
      autohealing = try(coalesce(local.cfg.default_node_pool.autohealing, null), true)

      container_runtime      = try(coalesce(local.cfg.default_node_pool.container_runtime, null), "containerd")
      root_volume_type       = try(local.cfg.default_node_pool.root_volume_type, null)
      root_volume_size_in_gb = try(local.cfg.default_node_pool.root_volume_size_in_gb, null)

      public_ip_disabled = try(coalesce(local.cfg.default_node_pool.public_ip_disabled, null), false)

      upgrade_policy = try(local.cfg.default_node_pool.upgrade_policy, null)

      kubelet_args = try(local.cfg.default_node_pool.kubelet_args, null)

      node_taints = try(local.cfg.default_node_pool.node_taints, null)
      tags        = try(local.cfg.default_node_pool.tags, null)
    }
  }
  configuration_base_key = terraform.workspace
}
