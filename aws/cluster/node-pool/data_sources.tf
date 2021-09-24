data "aws_eks_cluster" "current" {
  name = var.cluster_name
}

data "aws_eks_node_group" "default" {
  cluster_name    = data.aws_eks_cluster.current.name
  node_group_name = var.cluster_default_node_pool_name
}

data "aws_vpc" "current" {
  id = data.aws_eks_cluster.current.vpc_config[0].vpc_id
}

data "aws_route_table" "current" {
  subnet_id = local.vpc_subnet_ids[0]
}
