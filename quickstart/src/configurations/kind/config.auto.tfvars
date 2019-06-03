clusters = {
  kind_zero = {
    # Settings for Apps-cluster
    apps = {
      name_prefix = "testing"
      base_domain = "infra.local"

      node_roles = "control-plane,control-plane,control-plane,worker,worker,worker"
    }

    # Settings for Ops-cluster
    ops = {
      node_roles = "control-plane,worker,worker"
    }
  }
}
