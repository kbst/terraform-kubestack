module "eks_zero_node_pool_existing_subnets" {
  providers = {
    aws = aws.eks_zero
  }

  source = "../aws/cluster/node-pool"

  cluster_name = module.eks_zero.current_metadata["name"]

  configuration = {
    # Settings for Apps-cluster
    apps = {
      name = "existing-subnets"

      instance_types   = "t3a.medium"
      desired_capacity = 1
      min_size         = 1
      max_size         = 3
    }

    # Settings for Ops-cluster
    ops = {
      max_size = "1"
    }
  }
}

module "eks_zero_node_pool_new_subnets" {
  providers = {
    aws = aws.eks_zero
  }

  source = "../aws/cluster/node-pool"

  cluster_name = module.eks_zero.current_metadata["name"]

  configuration = {
    # Settings for Apps-cluster
    apps = {
      name = "new-subnets"

      instance_types   = "t3a.medium,t3a.small"
      desired_capacity = 1
      min_size         = 1
      max_size         = 3

      availability_zones = "eu-west-1a,eu-west-1b,eu-west-1c"

      # use the last three /18 subnets in the CIDR
      # https://www.davidc.net/sites/default/subnets/subnets.html?network=10.0.0.0&mask=16&division=23.ff4011
      vpc_subnet_newbits = 2

      taints = [
        {
          key    = "taint-key1"
          value  = "taint-value1"
          effect = "NO_SCHEDULE"
        },
        {
          key    = "taint-key2"
          value  = "taint-value2"
          effect = "PREFER_NO_SCHEDULE"
        }
      ]
    }

    # Settings for Ops-cluster
    ops = {
      max_size           = "1"
      availability_zones = "eu-west-1a,eu-west-1b"
    }
  }
}

module "eks_zero_node_pool_new_subnets_secondary_cidr" {
  providers = {
    aws = aws.eks_zero
  }

  source = "../aws/cluster/node-pool"

  cluster_name = module.eks_zero.current_metadata["name"]

  configuration = {
    # Settings for Apps-cluster
    apps = {
      name = "new-subnets-secondary-cidr"

      instance_types   = "t3a.medium,t3a.small"
      desired_capacity = 1
      min_size         = 1
      max_size         = 3

      availability_zones = "eu-west-1a,eu-west-1b,eu-west-1c"

      # add a secondary CIDR to the VPC and create subnets for it
      # https://www.davidc.net/sites/default/subnets/subnets.html?network=10.1.0.0&mask=16&division=23.ff4011
      vpc_secondary_cidr = "10.1.0.0/16"

      # with 3 zones we need at least 3 subnets, use the first three /18 subnets
      vpc_subnet_newbits       = 2
      vpc_subnet_number_offset = 0

      taints = [
        {
          key    = "taint-key"
          value  = "taint-value"
          effect = "NO_SCHEDULE"
        }
      ]
    }

    # Settings for Ops-cluster
    ops = {
      max_size           = "1"
      availability_zones = "eu-west-1a,eu-west-1b"

      # only two zones, use the two /17 subnets
      vpc_subnet_newbits = 1
    }
  }
}
