module "node_pool" {
  source = "./node_pool"

  metadata_name = var.metadata_name

  cluster_name     = aws_eks_cluster.current.name
  cluster_endpoint = aws_eks_cluster.current.endpoint
  cluster_version  = aws_eks_cluster.current.version
  cluster_ca       = aws_eks_cluster.current.certificate_authority[0].data

  iam_instance_profile_name = aws_iam_instance_profile.nodes.name

  security_groups = [aws_security_group.nodes.id]

  instance_type    = var.instance_type
  desired_capacity = var.desired_capacity
  max_size         = var.max_size
  min_size         = var.min_size

  vpc_zone_identifiers = [aws_subnet.current.*.id]
}

