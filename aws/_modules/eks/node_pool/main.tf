data "aws_ec2_instance_type" "current" {
  # ami_type is always determined by the first instance_type in the list
  instance_type = element(tolist(var.instance_types), 0)
}

locals {
  cpu_ami_type = data.aws_ec2_instance_type.current.supported_architectures[0] == "arm64" ? "AL2_ARM_64" : "AL2_x86_64"
  ami_type     = length(data.aws_ec2_instance_type.current.gpus) > 0 ? "AL2_x86_64_GPU" : local.cpu_ami_type
}

resource "aws_eks_node_group" "nodes" {
  cluster_name    = var.cluster_name
  node_group_name = var.node_group_name
  node_role_arn   = var.role_arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  version        = var.kubernetes_version
  ami_type       = var.ami_type == null ? local.ami_type : var.ami_type
  instance_types = var.instance_types
  disk_size      = var.disk_size

  tags   = merge(var.tags, var.eks_metadata_tags)
  labels = merge(var.labels, var.metadata_labels)

  dynamic "taint" {
    for_each = var.taints

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
