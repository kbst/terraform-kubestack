module "scw_zero" {
  source = "../scaleway/cluster"

  configuration = {
    # Settings for Apps-cluster
    apps = {
      name_prefix = "kbstacctest"
      base_domain = "infra.serverwolken.de"

      region = "fr-par"

      cluster_version = "1.32"
      cni             = "cilium"

      delete_additional_resources = false

      default_node_pool = {
        node_type   = "GP1-XS"
        zones       = ["fr-par-1", "fr-par-2", "fr-par-3"]
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
