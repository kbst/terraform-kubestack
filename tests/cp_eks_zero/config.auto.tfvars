clusters = {
  eks_zero = {
    # Settings for Apps-cluster
    apps = {
      name_prefix                = "testing"
      base_domain                = "infra.serverwolken.de"
      cluster_instance_type      = "t2.small"
      cluster_desired_capacity   = "1"
      cluster_min_size           = "1"
      cluster_max_size           = "1"
      cluster_availability_zones = "eu-west-1a,eu-west-1b,eu-west-1c"
    }

    # Settings for Ops-cluster
    ops = {
      cluster_max_size           = "1"
      cluster_availability_zones = "eu-west-1a,eu-west-1b"
    }
  }
}
