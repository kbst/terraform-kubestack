module "aks_zero" {
  source = "../azurerm/cluster"

  configuration = {
    # Settings for Apps-cluster
    apps = {
      resource_group = "terraform-kubestack-testing"
      name_prefix    = "kbstacctest"
      base_domain    = "infra.serverwolken.de"

      default_node_pool_vm_size   = "Standard_B2s"
      default_node_pool_min_count = 1
      default_node_pool_max_count = 1

      network_plugin = "azure"

      sku_tier = "Standard"
    }

    # Settings for Ops-cluster
    ops = {}
  }
}
