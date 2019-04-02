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
      cluster_min_master_version = "1.11.8"
      cluster_initial_node_count = 1
      region                     = "europe-west1"
      cluster_additional_zones   = "europe-west1-b,europe-west1-c,europe-west1-d"
    }

    # Settings for Ops-cluster
    ops = {
      cluster_additional_zones = "europe-west1-b"
    }
  }

  aks_zero = {
    # Settings for Apps-cluster
    apps = {
      resource_group = "terraform-kubestack-testing"
      name_prefix    = "testing"
      base_domain    = "infra.serverwolken.de"

      worker_nodes_name            = "default"
      worker_nodes_count           = "1"
      worker_nodes_vm_size         = "Standard_D1_v2"
      worker_nodes_os_type         = "Linux"
      worker_nodes_os_disk_size_gb = "30"
    }

    # Settings for Ops-cluster
    ops = {}
  }
}
