module "aks_zero_node_pool" {
  source = "../azurerm/cluster/node-pool"

  cluster = module.aks_zero.cluster

  configuration = {
    # Settings for Apps-cluster
    apps = {
      node_pool_name = "test1"

      availability_zones = ["1", "2", "3"]

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
