locals {
  // if provider level tags are set, the node_group data source tags attr
  // includes the resource level and provider level tags
  // we have to exclude the provider level tags when setting them for node pools below
  node_group_tag_keys        = toset(keys(data.aws_eks_node_group.default.tags))
  provider_level_tag_keys    = toset(keys(data.aws_default_tags.current.tags))
  tags_without_all_tags_keys = setsubtract(local.node_group_tag_keys, local.provider_level_tag_keys)
  tags_without_all_tags      = { for k in local.tags_without_all_tags_keys : k => data.aws_eks_node_group.default.tags[k] }
}

data "aws_ec2_instance_type" "current" {
  # ami_type is always determined by the first instance_type in the list
  instance_type = element(tolist(local.instance_types), 0)
}

locals {
  cpu_ami_type = data.aws_ec2_instance_type.current.supported_architectures[0] == "arm64" ? "AL2023_ARM_64_STANDARD" : "AL2023_x86_64_STANDARD"
  ami_type_computed     = length(data.aws_ec2_instance_type.current.gpus) > 0 ? "AL2023_x86_64_NVIDIA" : local.cpu_ami_type
}

resource "aws_eks_node_group" "nodes" {
  cluster_name    = data.aws_eks_cluster.current.name
  node_group_name = local.name
  node_role_arn   = data.aws_eks_node_group.default.node_role_arn
  subnet_ids      = local.vpc_subnet_newbits == null ? local.vpc_subnet_ids : aws_subnet.current.*.id

  scaling_config {
    desired_size = local.desired_capacity
    max_size     = local.max_size
    min_size     = local.min_size
  }

  version         = data.aws_eks_cluster.current.version
  ami_type        = local.ami_type == null ? local.ami_type_computed : local.ami_type
  release_version = local.ami_release_version
  instance_types  = local.instance_types

  disk_size = local.create_launch_template ? null : local.disk_size

  dynamic "launch_template" {
    for_each = local.create_launch_template ? toset([1]) : toset([])

    content {
      id      = aws_launch_template.current[0].id
      version = aws_launch_template.current[0].latest_version
    }
  }

  tags   = merge(local.tags, local.tags_without_all_tags)
  labels = merge(local.labels, data.aws_eks_node_group.default.labels)

  dynamic "taint" {
    for_each = local.taints

    content {
      key    = taint.value["key"]
      value  = taint.value["value"]
      effect = taint.value["effect"]
    }
  }

  # when autoscaler is enabled, desired_size needs to be ignored
  # better would be to handle this in the resource and not require
  # desired_size, min_size and max_size in scaling_config
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}
