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

  node_group_name = local.cfg["name"]

  subnet_ids = local.vpc_subnet_newbits == null ? local.vpc_subnet_ids : aws_subnet.current.*.id

  instance_types = local.cfg["instance_types"]
  desired_size   = local.cfg["desired_size"]
  max_size       = local.cfg["max_size"]
  min_size       = local.cfg["min_size"]

  ami_type = local.cfg["ami_type"]

  kubernetes_version = data.aws_eks_cluster.current.version

  disk_size = local.cfg["disk_size"]

  metadata_options = local.cfg["metadata_options"]

  taints = local.cfg["taints"]

  tags = local.cfg["tags"]

  labels = local.cfg["labels"]

  depends-on-aws-auth = null
}
