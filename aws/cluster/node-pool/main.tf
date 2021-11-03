module "node_pool" {
  source = "../../_modules/eks/node_pool"

  cluster_name      = data.aws_eks_cluster.current.name
  metadata_labels   = data.aws_eks_node_group.default.labels
  eks_metadata_tags = data.aws_eks_node_group.default.tags
  role_arn          = data.aws_eks_node_group.default.node_role_arn

  node_group_name = local.name

  subnet_ids = local.vpc_subnet_newbits == null ? local.vpc_subnet_ids : aws_subnet.current.*.id

  instance_types = local.instance_types
  desired_size   = local.desired_capacity
  max_size       = local.max_size
  min_size       = local.min_size

  ami_type = local.ami_type

  kubernetes_version = data.aws_eks_cluster.current.version

  disk_size = local.disk_size

  taints = local.taints

  tags = local.tags

  labels = local.labels

  depends-on-aws-auth = null
}
