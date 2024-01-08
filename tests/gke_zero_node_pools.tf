module "gke_zero_node_pool" {
  source = "../google/cluster/node-pool"

  cluster_metadata = module.gke_zero.current_metadata

  configuration = {
    # Settings for Apps-cluster
    apps = {
      project_id = "terraform-kubestack-testing"

      name = "test1"

      machine_type   = "e2-medium"
      min_node_count = 1
      max_node_count = 1

      location       = module.gke_zero.current_config["region"]
      node_locations = ["europe-west1-c", "europe-west1-d"]

      taints = [
        {
          effect = "NO_SCHEDULE"
          key    = "nvidia.com/gpu"
          value  = "present"
        },
      ]
    }

    # Settings for Ops-cluster
    ops = {}
  }
}
