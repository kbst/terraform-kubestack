locals {
  create_launch_template     = local.cfg.metadata_options != null
  launch_template_name_parts = join("-", [var.cluster.name, local.cfg.name])
  launch_template_name_hash  = sha256(local.launch_template_name_parts)
  launch_template_name       = "${substr(local.launch_template_name_parts, 0, 120)}-${substr(local.launch_template_name_hash, 0, 7)}"

  cpu_ami_name       = data.aws_ec2_instance_type.current.supported_architectures[0] == "arm64" ? "amazon-linux-2023/arm64/standard" : "amazon-linux-2023/x86_64/standard"
  is_gpu             = length(data.aws_ec2_instance_type.current.gpus) > 0
  ami_name           = local.is_gpu ? "amazon-linux-2023/x86_64/nvidia" : local.cpu_ami_name
  ami_release_prefix = local.is_gpu ? "amazon-eks-gpu-node" : "amazon-eks-node"
  ami_release_date   = local.cfg.ami_release_version == null ? "" : split("-", local.cfg.ami_release_version)[1]
  ami_release_name   = local.cfg.ami_release_version == null ? "recommended" : "${local.ami_release_prefix}-${var.cluster.version}-v${local.ami_release_date}"
}

data "aws_ssm_parameter" "eks_ami_release_version" {
  count = try(coalesce(local.cfg.disk_size, null), 20) != null ? 1 : 0

  name = "/aws/service/eks/optimized-ami/${var.cluster.version}/${local.ami_name}/${local.ami_release_name}/image_id"
}

data "aws_ami" "eks_optimized" {
  count = try(coalesce(local.cfg.disk_size, null), 20) != null ? 1 : 0

  owners = ["amazon"]

  filter {
    name   = "image-id"
    values = [nonsensitive(data.aws_ssm_parameter.eks_ami_release_version[0].value)]
  }
}

resource "aws_launch_template" "current" {
  count = local.create_launch_template ? 1 : 0

  name = local.launch_template_name

  tags = coalesce(local.cfg.tags, {})

  dynamic "block_device_mappings" {
    for_each = try(coalesce(local.cfg.disk_size, null), 20) != null ? toset([1]) : toset([])

    content {
      device_name = data.aws_ami.eks_optimized[0].root_device_name

      ebs {
        volume_size = try(coalesce(local.cfg.disk_size, null), 20)
      }
    }
  }

  dynamic "metadata_options" {
    for_each = local.cfg.metadata_options != null ? toset([1]) : toset([])

    content {
      http_endpoint               = local.cfg.metadata_options.http_endpoint
      http_tokens                 = local.cfg.metadata_options.http_tokens
      http_put_response_hop_limit = local.cfg.metadata_options.http_put_response_hop_limit
      http_protocol_ipv6          = local.cfg.metadata_options.http_protocol_ipv6
      instance_metadata_tags      = local.cfg.metadata_options.instance_metadata_tags
    }
  }
}
