module "node_pool" {
  source = "./node_pool"

  metadata_name   = var.metadata_name
  metadata_labels = var.metadata_labels

  pool_name = "default"

  eks_metadata_tags = local.eks_metadata_tags

  cluster_name     = aws_eks_cluster.current.name
  cluster_endpoint = aws_eks_cluster.current.endpoint
  cluster_version  = aws_eks_cluster.current.version
  cluster_ca       = aws_eks_cluster.current.certificate_authority[0].data

  iam_instance_profile_name = aws_iam_instance_profile.nodes.name
  role_arn                  = aws_iam_role.node.arn

  security_groups = [aws_security_group.nodes.id]

  instance_type    = var.instance_type
  desired_capacity = var.desired_capacity
  max_size         = var.max_size
  min_size         = var.min_size

  root_device_volume_size = var.root_device_volume_size
  root_device_encrypted   = var.root_device_encrypted

  vpc_zone_identifiers = aws_subnet.current.*.id
}
