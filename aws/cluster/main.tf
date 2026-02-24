module "configuration" {
  source        = "../../common/configuration"
  configuration = var.configuration
  base_key      = var.configuration_base_key
}

locals {
  cfg = module.configuration.merged[terraform.workspace]
}

data "aws_region" "current" {
}

module "cluster_metadata" {
  source = "../../common/metadata"

  name_prefix = local.cfg.name_prefix
  base_domain = local.cfg.base_domain

  provider_name   = "aws"
  provider_region = data.aws_region.current.name
}

# AWS refers to labels (key-value pairs) as tags.
# EKS also requires below specific tag set. This is why we merge this one
# and our default labels from metadata here into eks_tags to use throughout
# the eks module.
locals {
  eks_tags = {
    "kubernetes.io/cluster/${module.cluster_metadata.name}" = "shared"
  }

  eks_metadata_tags = merge(module.cluster_metadata.labels, local.eks_tags)
}

data "aws_partition" "current" {}

data "aws_eks_cluster_auth" "current" {
  name = aws_eks_cluster.current.name
}

resource "aws_eks_cluster" "current" {
  name     = module.cluster_metadata.name
  role_arn = aws_iam_role.master.arn

  vpc_config {
    security_group_ids      = [aws_security_group.masters.id]
    subnet_ids              = aws_subnet.current[*].id
    endpoint_private_access = try(coalesce(local.cfg.cluster_endpoint_private_access, null), false)
    endpoint_public_access  = try(coalesce(local.cfg.cluster_endpoint_public_access, null), true)
    public_access_cidrs     = local.cfg.cluster_public_access_cidrs
  }

  dynamic "kubernetes_network_config" {
    for_each = local.cfg.cluster_service_cidr != null ? toset([1]) : toset([])
    content {
      service_ipv4_cidr = local.cfg.cluster_service_cidr
    }
  }

  dynamic "encryption_config" {
    for_each = local.cfg.cluster_encryption_key_arn != null ? toset([1]) : toset([])
    content {
      resources = ["secrets"]

      provider {
        key_arn = local.cfg.cluster_encryption_key_arn
      }
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.master_cluster_policy,
    aws_iam_role_policy_attachment.master_service_policy,
  ]

  version = local.cfg.cluster_version

  enabled_cluster_log_types = try(coalesce(local.cfg.enabled_cluster_log_types, null), ["api", "audit", "authenticator", "controllerManager", "scheduler"])
}
