clusters = {
  kind_zero = {
    # Settings for Apps-cluster
    apps = {
      name_prefix = "kind"
      base_domain = "infra.127.0.0.1.xip.io"

      # clusters always have at least one control-plane node
      # uncommenting extra_nodes below will give you a cluster
      # with 3 control-plane nodes and 3 worker nodes
      # extra_nodes = "control-plane,control-plane,worker,worker,worker"
    }

    # Settings for Ops-cluster
    ops = {
      # optionally reduce number of ops nodes
      # extra_nodes = "worker"
    }
  }
}
