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

  gke_zero = {
    # Settings for Apps-cluster
    apps = {
      project_id                 = "terraform-kubestack-testing"
      name_prefix                = "testing"
      base_domain                = "infra.serverwolken.de"
      cluster_min_master_version = "1.13.6"
      cluster_initial_node_count = 1
      region                     = "europe-west1"
      cluster_node_locations     = "europe-west1-b,europe-west1-c,europe-west1-d"
    }

    # Settings for Ops-cluster
    ops = {
      cluster_node_locations = "europe-west1-b"
    }
  }

  aks_zero = {
    # Settings for Apps-cluster
    apps = {
      resource_group = "terraform-kubestack-testing"
      name_prefix    = "testing"
      base_domain    = "infra.serverwolken.de"
    }

    # Settings for Ops-cluster
    ops = {}
  }
}
