data "aws_ami" "eks_node" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.cluster_version}-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}

locals {
  node_userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${var.cluster_endpoint}' --b64-cluster-ca '${var.cluster_ca}' '${var.cluster_name}'
USERDATA

}

resource "aws_launch_configuration" "nodes" {
  associate_public_ip_address = true
  iam_instance_profile = var.iam_instance_profile_name
  image_id = data.aws_ami.eks_node.id
  instance_type = var.instance_type
  name_prefix = var.metadata_name
  security_groups = var.security_groups
  user_data_base64 = base64encode(local.node_userdata)

  root_block_device {
    volume_size = var.root_device_volume_size
    encrypted = var.root_device_encrypted
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "nodes" {
  desired_capacity = var.desired_capacity
  launch_configuration = aws_launch_configuration.nodes.id
  max_size = var.max_size
  min_size = var.min_size
  name = var.metadata_name
  vpc_zone_identifier = var.vpc_zone_identifiers

  tag {
    key = "Name"
    value = var.metadata_name
    propagate_at_launch = true
  }

  tag {
    key = "kubernetes.io/cluster/${var.metadata_name}"
    value = "owned"
    propagate_at_launch = true
  }
}

