module "scw_zero" {
  source = "../scaleway/cluster"

  configuration = {
    # Settings for Apps-cluster
    apps = {
      name_prefix = "kbstacctest"
      base_domain = "infra.serverwolken.de"

      region = "nl-ams"

      cluster_version = "1.35"
      cni             = "cilium"

      delete_additional_resources = false

      default_node_pool = {
        node_type   = "PLAY2-MICRO"
        zones       = ["nl-ams-1", "nl-ams-2", "nl-ams-3"]
        size        = 1
        min_size    = 1
        max_size    = 2
        autoscaling = true
        autohealing = true
      }
    }

    # Settings for Ops-cluster
    ops = {}
  }
}
