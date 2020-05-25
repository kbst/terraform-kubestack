module "node_pool" {
  source = "./node_pool"

  metadata_labels   = var.metadata_labels
  eks_metadata_tags = local.eks_metadata_tags

  cluster_name    = aws_eks_cluster.current.name
  node_group_name = "default"

  role_arn = aws_iam_role.node.arn

  subnet_ids = aws_subnet.current.*.id

  instance_type = var.instance_type
  desired_size  = var.desired_capacity
  max_size      = var.max_size
  min_size      = var.min_size

  disk_size = var.root_device_volume_size
}
