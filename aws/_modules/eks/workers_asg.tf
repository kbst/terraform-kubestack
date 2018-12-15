data "aws_ami" "eks_node" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}

locals {
  node_userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.current.endpoint}' --b64-cluster-ca '${aws_eks_cluster.current.certificate_authority.0.data}' '${aws_eks_cluster.current.name}'
USERDATA
}

resource "aws_launch_configuration" "nodes" {
  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.nodes.name}"
  image_id                    = "${data.aws_ami.eks_node.id}"
  instance_type               = "${var.instance_type}"
  name_prefix                 = "${var.metadata_name}"
  security_groups             = ["${aws_security_group.nodes.id}"]
  user_data_base64            = "${base64encode(local.node_userdata)}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "nodes" {
  desired_capacity     = "${var.desired_capacity}"
  launch_configuration = "${aws_launch_configuration.nodes.id}"
  max_size             = "${var.max_size}"
  min_size             = "${var.min_size}"
  name                 = "${var.metadata_name}"
  vpc_zone_identifier  = ["${aws_subnet.current.*.id}"]

  tag {
    key                 = "Name"
    value               = "${var.metadata_name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.metadata_name}"
    value               = "owned"
    propagate_at_launch = true
  }
}
