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

data "aws_subnet_ids" "current" {
  count = length(local.availability_zones) > 0 ? 1 : 0

  vpc_id = data.aws_vpc.current.id

  # if the node pool is in one or more specific AZs
  # only link subnet_ids belonging to these AZs
  filter {
    name   = "availability-zone"
    values = local.availability_zones
  }

  # exclude control plane subnets
  filter {
    name   = "subnet-id"
    values = tolist(data.aws_eks_node_group.default.subnet_ids)
  }
}

data "aws_route_table" "current" {
  subnet_id = local.vpc_subnet_ids[0]
}
