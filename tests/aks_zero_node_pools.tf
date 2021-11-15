module "aks_zero_node_pool" {
  source = "../azurerm/cluster/node-pool"

  cluster_name   = module.aks_zero.current_metadata["name"]
  resource_group = module.aks_zero.current_config["resource_group"]

  configuration = {
    # Settings for Apps-cluster
    apps = {
      node_pool_name = "test1"

      vm_size   = "Standard_B2s"
      min_count = 1
      max_count = 1

      node_taints = [
        "nvidia.com/gpu=present:NoSchedule"
      ]
    }

    # Settings for Ops-cluster
    ops = {}
  }
}
