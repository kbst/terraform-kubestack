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

data "aws_internet_gateway" "current" {
  count = local.vpc_subnet_newbits == null ? 0 : 1

  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.current.id]
  }
}

data "aws_nat_gateway" "current" {
  count = local.vpc_subnet_newbits == null ? 0 : length(local.availability_zones)

  vpc_id = data.aws_vpc.current.id

  tags = {
    "kubestack.com/cluster_name"          = data.aws_eks_cluster.current.name
    "kubestack.com/cluster_provider_zone" = local.availability_zones[count.index]
  }
}
