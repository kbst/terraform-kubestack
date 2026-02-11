locals {
  create_launch_template = local.metadata_options != null ? true : false

  launch_template_name_parts = join("-", [data.aws_eks_cluster.current.name, local.name])
  launch_template_name_hash  = sha256(local.launch_template_name_parts)
  launch_template_name       = "${substr(local.launch_template_name_parts, 0, 120)}-${substr(local.launch_template_name_hash, 0, 7)}"

  cpu_ami_name       = data.aws_ec2_instance_type.current.supported_architectures[0] == "arm64" ? "amazon-linux-2-arm64" : "amazon-linux-2"
  is_gpu             = length(data.aws_ec2_instance_type.current.gpus) > 0
  ami_name           = local.is_gpu ? "amazon-linux-2-gpu" : local.cpu_ami_name
  ami_release_prefix = local.is_gpu ? "amazon-eks-gpu-node" : "amazon-eks-node"
  ami_release_date   = local.ami_release_version == null ? "" : split("-", local.ami_release_version)[1]
  ami_release_name   = local.ami_release_version == null ? "recommended" : "${local.ami_release_prefix}-${data.aws_eks_cluster.current.version}-v${local.ami_release_date}"
}

data "aws_ssm_parameter" "eks_ami_release_version" {
  count = local.disk_size != null ? 1 : 0

  name = "/aws/service/eks/optimized-ami/${data.aws_eks_cluster.current.version}/${local.ami_name}/${local.ami_release_name}/image_id"
}

data "aws_ami" "eks_optimized" {
  count = local.disk_size != null ? 1 : 0

  owners = ["amazon"]

  filter {
    name   = "image-id"
    values = [nonsensitive(data.aws_ssm_parameter.eks_ami_release_version[0].value)]
  }
}

resource "aws_launch_template" "current" {
  count = local.create_launch_template ? 1 : 0

  name = local.launch_template_name

  tags = merge(local.tags, local.tags_without_all_tags)

  dynamic "block_device_mappings" {
    for_each = local.disk_size != null ? toset([1]) : toset([])

    content {
      device_name = data.aws_ami.eks_optimized[0].root_device_name

      ebs {
        volume_size = local.disk_size
      }
    }
  }

  dynamic "metadata_options" {
    for_each = local.metadata_options != null ? toset([1]) : toset([])

    content {
      http_endpoint               = local.metadata_options.http_endpoint
      http_tokens                 = local.metadata_options.http_tokens
      http_put_response_hop_limit = local.metadata_options.http_put_response_hop_limit
      http_protocol_ipv6          = local.metadata_options.http_protocol_ipv6
      instance_metadata_tags      = local.metadata_options.instance_metadata_tags
    }
  }
}
