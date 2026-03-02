module "configuration" {
  source        = "../../../common/configuration"
  configuration = var.configuration
  base_key      = var.configuration_base_key
}

locals {
  cfg = module.configuration.merged[terraform.workspace]

  cpu_ami_type      = data.aws_ec2_instance_type.current.supported_architectures[0] == "arm64" ? "AL2023_ARM_64_STANDARD" : "AL2023_x86_64_STANDARD"
  computed_ami_type = length(data.aws_ec2_instance_type.current.gpus) > 0 ? "AL2023_x86_64_NVIDIA" : local.cpu_ami_type
}

resource "aws_eks_node_group" "nodes" {
  cluster_name    = var.cluster.name
  node_group_name = local.cfg.name
  node_role_arn   = data.aws_iam_role.node.arn

  lifecycle {
    # when autoscaler is enabled, desired_size needs to be ignored
    ignore_changes = [scaling_config[0].desired_size]

    precondition {
      condition     = local.cfg.availability_zones != null
      error_message = "missing required configuration attribute: availability_zones"
    }

    precondition {
      condition     = local.cfg.instance_types != null
      error_message = "missing required configuration attribute: instance_types"
    }

    precondition {
      condition     = local.cfg.min_size != null
      error_message = "missing required configuration attribute: min_size"
    }

    precondition {
      condition     = local.cfg.max_size != null
      error_message = "missing required configuration attribute: max_size"
    }
  }

  subnet_ids = coalesce(
    # first prio, user specified subnet ids
    try(coalesce(var.cluster_default_node_pool_subnet_ids, local.cfg.vpc_subnet_ids), null),
    # second prio, created subnet ids
    length(aws_subnet.current.*.id) > 0 ? aws_subnet.current.*.id : null,
    # fall back, existing subnet ids
    length(data.aws_subnets.current) == 1 ? data.aws_subnets.current[0].ids : null,
  )

  scaling_config {
    desired_size = local.cfg.desired_capacity
    max_size     = local.cfg.max_size
    min_size     = local.cfg.min_size
  }

  version         = var.cluster.version
  ami_type        = local.cfg.ami_type == null ? local.computed_ami_type : local.cfg.ami_type
  release_version = local.cfg.ami_release_version
  instance_types  = try(toset(local.cfg.instance_types), toset([]))

  disk_size = local.create_launch_template ? null : try(coalesce(local.cfg.disk_size, null), 20)

  dynamic "launch_template" {
    for_each = local.create_launch_template ? toset([1]) : toset([])

    content {
      id      = aws_launch_template.current[0].id
      version = aws_launch_template.current[0].latest_version
    }
  }

  tags = merge(
    { "kubernetes.io/cluster/${var.cluster.name}" = "shared" },
    var.cluster_metadata.labels,
    coalesce(local.cfg.tags, {})
  )
  labels = merge(var.cluster_metadata.labels, coalesce(local.cfg.labels, {}))

  dynamic "taint" {
    for_each = coalesce(local.cfg.taints, [])

    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }
}
