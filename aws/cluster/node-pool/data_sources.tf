data "aws_iam_role" "node" {
  name = "${var.cluster.name}-node"
}

data "aws_vpc" "cluster" {
  id = var.cluster.vpc_config[0].vpc_id
}

data "aws_eks_node_group" "default" {
  count = var.cluster_default_node_pool_subnet_ids == null ? 1 : 0

  cluster_name    = var.cluster.name
  node_group_name = var.cluster_default_node_pool_name
}

data "aws_subnets" "current" {
  count = var.cluster_default_node_pool_subnet_ids == null ? 1 : 0

  filter {
    name   = "vpc-id"
    values = [var.cluster.vpc_config[0].vpc_id]
  }

  # if the node pool is in one or more specific AZs
  # only link subnet_ids belonging to these AZs
  filter {
    name   = "availability-zone"
    values = coalesce(local.cfg.availability_zones, [])
  }

  # exclude control plane subnets
  filter {
    name   = "subnet-id"
    values = tolist(data.aws_eks_node_group.default[0].subnet_ids)
  }
}


data "aws_internet_gateway" "current" {
  count = local.cfg.vpc_subnet_newbits == null ? 0 : local.cfg.vpc_subnet_map_public_ip == false ? 0 : 1

  filter {
    name   = "attachment.vpc-id"
    values = [var.cluster.vpc_config[0].vpc_id]
  }
}

data "aws_nat_gateway" "current" {
  count = local.cfg.vpc_subnet_newbits == null ? 0 : local.cfg.vpc_subnet_map_public_ip == false ? length(lookup(local.cfg, "availability_zones", [])) : 0

  vpc_id = var.cluster.vpc_config[0].vpc_id

  tags = {
    "kubestack.com/cluster_name"          = var.cluster.name
    "kubestack.com/cluster_provider_zone" = local.cfg.availability_zones[count.index]
  }
}

data "aws_ec2_instance_type" "current" {
  # ami_type is always determined by the first instance_type in the list
  # fall back to t3.medium when no instance_types are configured
  instance_type = element(coalesce(local.cfg.instance_types, ["t3.medium"]), 0)
}
