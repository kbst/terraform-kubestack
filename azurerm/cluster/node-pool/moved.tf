moved {
  from = module.node_pool.azurerm_kubernetes_cluster_node_pool.current
  to   = azurerm_kubernetes_cluster_node_pool.current
}
