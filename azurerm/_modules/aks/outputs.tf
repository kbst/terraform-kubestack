
output "node_resource_group" {
  value = azurerm_kubernetes_cluster.current.node_resource_group
}

output "aks_nsg_id" {
  value = data.external.aks_nsg_id.result.output
}
