clusters = {
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
