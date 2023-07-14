locals {
  create_launch_template = var.metadata_options != null ? true : false

  launch_template_name_parts = join("-", [var.cluster_name, var.node_group_name])
  launch_template_name_hash  = sha256(local.launch_template_name_parts)
  launch_template_name       = "${substr(local.launch_template_name_parts, 0, 120)}-${substr(local.launch_template_name_hash, 0, 7)}"

  cpu_ami_name = data.aws_ec2_instance_type.current.supported_architectures[0] == "arm64" ? "amazon-linux-2-arm64" : "amazon-linux-2"
  ami_name     = length(data.aws_ec2_instance_type.current.gpus) > 0 ? "amazon-linux-2-gpu" : local.cpu_ami_name
}

data "aws_ssm_parameter" "eks_ami_release_version" {
  count = var.disk_size != null ? 1 : 0

  name = "/aws/service/eks/optimized-ami/${var.kubernetes_version}/${local.ami_name}/recommended/image_id"
}

data "aws_ami" "eks_optimized" {
  count = var.disk_size != null ? 1 : 0

  owners = ["amazon"]

  filter {
    name   = "image-id"
    values = [nonsensitive(data.aws_ssm_parameter.eks_ami_release_version[0].value)]
  }
}

resource "aws_launch_template" "current" {
  count = local.create_launch_template ? 1 : 0

  name = local.launch_template_name

  tags = merge(var.tags, var.eks_metadata_tags)

  dynamic "block_device_mappings" {
    for_each = var.disk_size != null ? toset([1]) : toset([])

    content {
      device_name = data.aws_ami.eks_optimized[0].root_device_name

      ebs {
        volume_size = var.disk_size
      }
    }
  }

  dynamic "metadata_options" {
    for_each = var.metadata_options != null ? toset([1]) : toset([])

    content {
      http_endpoint               = var.metadata_options.http_endpoint
      http_tokens                 = var.metadata_options.http_tokens
      http_put_response_hop_limit = var.metadata_options.http_put_response_hop_limit
      http_protocol_ipv6          = var.metadata_options.http_protocol_ipv6
      instance_metadata_tags      = var.metadata_options.instance_metadata_tags
    }
  }
}
