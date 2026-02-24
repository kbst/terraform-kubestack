output "cluster" {
  value = azurerm_kubernetes_cluster.current
}

output "aks_vnet" {
  value = length(azurerm_virtual_network.current) > 0 ? azurerm_virtual_network.current[0] : null
}

output "current_config" {
  value = local.cfg
}

output "current_metadata" {
  value = module.cluster_metadata
}

output "kubeconfig" {
  sensitive = true
  value     = local.kubeconfig
}

output "default_ingress_ip" {
  value = length(azurerm_public_ip.current) > 0 ? azurerm_public_ip.current[0].ip_address : null
}
