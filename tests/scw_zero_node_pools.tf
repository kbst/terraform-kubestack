module "scw_zero_node_pool" {
  source = "../scaleway/cluster/node-pool"

  cluster          = module.scw_zero.cluster
  cluster_metadata = module.scw_zero.current_metadata

  configuration = {
    # Settings for Apps-cluster
    apps = {
      name = "test1"

      node_type   = "PLAY2-MICRO"
      zones       = ["nl-ams-1", "nl-ams-2", "nl-ams-3"]
      size        = 1
      min_size    = 1
      max_size    = 2
      autoscaling = true
      autohealing = true

      node_taints = [
        {
          key    = "dedicated"
          value  = "test"
          effect = "NoSchedule"
        },
      ]
    }

    # Settings for Ops-cluster
    ops = {}
  }
}
