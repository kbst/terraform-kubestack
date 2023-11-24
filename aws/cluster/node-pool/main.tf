locals {
  // if provider level tags are set, the node_group data source tags attr
  // includes the resource level and provider level tags
  // we have to exclude the provider level tags when setting them for node pools below
  node_group_tag_keys        = toset(keys(data.aws_eks_node_group.default.tags))
  provider_level_tag_keys    = toset(keys(data.aws_default_tags.current.tags))
  tags_without_all_tags_keys = setsubtract(local.node_group_tag_keys, local.provider_level_tag_keys)
  tags_without_all_tags      = { for k in local.tags_without_all_tags_keys : k => data.aws_eks_node_group.default.tags[k] }
}

module "node_pool" {
  source = "../../_modules/eks/node_pool"

  cluster_name      = data.aws_eks_cluster.current.name
  metadata_labels   = data.aws_eks_node_group.default.labels
  eks_metadata_tags = local.tags_without_all_tags
  role_arn          = data.aws_eks_node_group.default.node_role_arn

  node_group_name = local.name

  subnet_ids = local.vpc_subnet_newbits == null ? local.vpc_subnet_ids : aws_subnet.current.*.id

  instance_types      = local.instance_types
  ami_release_version = local.ami_release_version
  desired_size        = local.desired_capacity
  max_size            = local.max_size
  min_size            = local.min_size

  ami_type = local.ami_type

  kubernetes_version = data.aws_eks_cluster.current.version

  disk_size = local.disk_size

  metadata_options = local.metadata_options

  taints = local.taints

  tags = local.tags

  labels = local.labels

  depends-on-aws-auth = null
}
