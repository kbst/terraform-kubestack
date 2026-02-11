module "node_pool" {
  source = "./node-pool"

  cluster_name = aws_eks_cluster.current.name

  configuration = {
    (terraform.workspace) = {
      name = "default"

      instance_types   = join(",", local.cluster_instance_types)
      desired_capacity = local.cluster_desired_capacity
      min_size         = local.cluster_min_size
      max_size         = local.cluster_max_size
      disk_size        = local.worker_root_device_volume_size

      ami_type            = local.worker_ami_type
      ami_release_version = local.worker_ami_release_version

      metadata_options = local.metadata_options

      vpc_subnet_ids = join(",", local.cluster_vpc_legacy_node_subnets ? aws_subnet.current.*.id : aws_subnet.node_pool.*.id)

      taints = []

      tags = local.cluster_additional_node_tags

      labels = {}
    }
  }
}
