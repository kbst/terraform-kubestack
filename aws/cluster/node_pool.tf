module "node_pool" {
  source = "./node-pool"

  cluster = aws_eks_cluster.current
  cluster_default_node_pool_subnet_ids = (
    local.cfg.cluster_vpc_legacy_node_subnets == true ?
    aws_subnet.current.*.id : aws_subnet.node_pool.*.id
  )

  configuration = {
    (terraform.workspace) = {
      name = "default"

      availability_zones  = try(local.cfg.cluster_availability_zones, null)
      instance_types      = try(local.cfg.default_node_pool.instance_types, null)
      ami_type            = try(local.cfg.default_node_pool.ami_type, null)
      ami_release_version = try(local.cfg.default_node_pool.ami_release_version, null)
      desired_capacity    = try(coalesce(local.cfg.default_node_pool.desired_capacity, null), 1)
      min_size            = try(local.cfg.default_node_pool.min_size, null)
      max_size            = try(local.cfg.default_node_pool.max_size, null)
      disk_size           = try(coalesce(local.cfg.default_node_pool.root_device_volume_size, null), 20)

      metadata_options = try(local.cfg.default_node_pool.metadata_options, null)

      taints = toset([])
      labels = try(coalesce(local.cfg.default_node_pool.labels, null), {})
      tags   = try(coalesce(local.cfg.default_node_pool.additional_node_tags, null), {})
    }
  }
  configuration_base_key = terraform.workspace

  cluster_metadata = module.cluster_metadata

  depends_on = [kubernetes_config_map.current]
}
