clusters = {
  gke_zero = {
    # Settings for Apps-cluster
    apps = {
      project_id                 = "terraform-kubestack-testing"
      name_prefix                = "testing"
      base_domain                = "infra.serverwolken.de"
      cluster_min_master_version = "1.13.6"
      cluster_min_node_count     = 1
      cluster_max_node_count     = 1
      region                     = "europe-west1"
      cluster_node_locations     = "europe-west1-b,europe-west1-c,europe-west1-d"
    }

    # Settings for Ops-cluster
    ops = {
      cluster_node_locations = "europe-west1-b"
    }
  }
}
