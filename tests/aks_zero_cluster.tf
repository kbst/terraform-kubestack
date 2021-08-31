module "aks_zero" {
  source = "../azurerm/cluster"

  configuration = {
    # Settings for Apps-cluster
    apps = {
      resource_group = "terraform-kubestack-testing"
      name_prefix    = "kbstacctest"
      base_domain    = var.base_domain

      default_node_pool_vm_size   = "Standard_B2s"
      default_node_pool_min_count = 1
      default_node_pool_max_count = 1

      network_plugin = "azure"
    }

    # Settings for Ops-cluster
    ops = {}
  }
}
