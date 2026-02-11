data "aws_region" "current" {
}

module "cluster_metadata" {
  source = "../../common/metadata"

  name_prefix = local.name_prefix
  base_domain = local.base_domain

  provider_name   = "aws"
  provider_region = data.aws_region.current.name
}

resource "aws_eks_cluster" "current" {
  name     = module.cluster_metadata.name
  role_arn = aws_iam_role.master.arn

  vpc_config {
    security_group_ids      = [aws_security_group.masters.id]
    subnet_ids              = aws_subnet.current.*.id
    endpoint_private_access = local.cluster_endpoint_private_access
    endpoint_public_access  = local.cluster_endpoint_public_access
    public_access_cidrs     = local.cluster_public_access_cidrs
  }

  dynamic "kubernetes_network_config" {
    for_each = local.cluster_service_cidr != null ? toset([1]) : toset([])
    content {
      service_ipv4_cidr = local.cluster_service_cidr
    }
  }

  dynamic "encryption_config" {
    for_each = local.cluster_encryption_key_arn != null ? toset([1]) : toset([])
    content {
      resources = ["secrets"]

      provider {
        key_arn = local.cluster_encryption_key_arn
      }
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.master_cluster_policy,
    aws_iam_role_policy_attachment.master_service_policy,
  ]

  version = local.cluster_version

  enabled_cluster_log_types = local.enabled_cluster_log_types
}
