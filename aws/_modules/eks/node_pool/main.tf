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

  instance_types = [var.instance_type]
  disk_size      = var.disk_size

  tags   = var.eks_metadata_tags
  labels = var.metadata_labels

  depends_on = [var.depends-on-aws-auth]
}
