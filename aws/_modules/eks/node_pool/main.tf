data "kubernetes_config_map" "aws_auth" {
  # Force an explicit depends_on, on the configmap
  # before creating the node pool
  # Otherwise the aws_eks_node_group resource
  # creates the configmap leaving TF to error
  # out because it already exists

  metadata {
    name      = var.depends-on-aws-auth.name
    namespace = var.depends-on-aws-auth.namespace
  }
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

  instance_types = [var.instance_type]
  disk_size      = var.disk_size

  tags   = var.eks_metadata_tags
  labels = var.metadata_labels

  depends_on = [data.kubernetes_config_map.aws_auth]
}
