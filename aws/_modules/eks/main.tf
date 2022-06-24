# AWS refers to labels (key-value pairs) as tags.
# EKS also requires below specifc tag set. This is why we merge this one
# and our default labels from metadata here into eks_tags to use throughout
# the eks module.
locals {
  eks_tags = {
    "kubernetes.io/cluster/${var.metadata_name}" = "shared"
  }

  eks_metadata_tags = merge(var.metadata_labels, local.eks_tags)
}

data "aws_partition" "current" {}

data "aws_eks_cluster_auth" "current" {
  name = aws_eks_cluster.current.name
}
