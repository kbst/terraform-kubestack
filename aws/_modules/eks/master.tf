resource "aws_eks_cluster" "current" {
  name     = var.metadata_name
  role_arn = aws_iam_role.master.arn

  vpc_config {
    security_group_ids      = [aws_security_group.masters.id]
    subnet_ids              = aws_subnet.current.*.id
    endpoint_private_access = var.cluster_endpoint_private_access
    endpoint_public_access  = var.cluster_endpoint_public_access
    public_access_cidrs     = var.cluster_public_access_cidrs
  }

  dynamic "kubernetes_network_config" {
    for_each = var.cluster_service_cidr != null ? toset([1]) : toset([])
    content {
      service_ipv4_cidr = var.cluster_service_cidr
    }
  }

  dynamic "encryption_config" {
    for_each = var.cluster_encryption_key_arn != null ? toset([1]) : toset([])
    content {
      resources = ["secrets"]

      provider {
        key_arn = var.cluster_encryption_key_arn
      }
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.master_cluster_policy,
    aws_iam_role_policy_attachment.master_service_policy,
  ]

  version = var.cluster_version

  enabled_cluster_log_types = var.enabled_cluster_log_types
}
