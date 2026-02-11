# Moved blocks to maintain state compatibility after refactoring
# These blocks ensure that node pool resources are not recreated when upgrading
# from the old module structure to the new flattened structure.

moved {
  from = module.node_pool.azurerm_kubernetes_cluster_node_pool.current
  to   = azurerm_kubernetes_cluster_node_pool.current
}
