module "gke_zero" {
  source = "../google/cluster"

  configuration = {
    # Settings for Apps-cluster
    apps = {
      project_id  = "terraform-kubestack-testing"
      name_prefix = "kbstacctest"
      base_domain = "infra.serverwolken.de"

      cluster_min_master_version = "1.19"

      cluster_machine_type   = "e2-medium"
      cluster_min_node_count = 1
      cluster_max_node_count = 1

      region                 = "europe-west1"
      cluster_node_locations = "europe-west1-b,europe-west1-c,europe-west1-d"
    }

    # Settings for Ops-cluster
    ops = {}
  }
}
