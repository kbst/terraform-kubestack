output "aks_vnet" {
  value = length(azurerm_virtual_network.current) > 0 ? azurerm_virtual_network.current[0] : null
}

output "kubeconfig" {
  sensitive = true
  value     = data.template_file.kubeconfig.rendered
}

output "kubeconfig_dummy" {
  sensitive = true
  value     = data.template_file.kubeconfig_dummy.rendered
}

output "default_ingress_ip" {
  value = length(azurerm_public_ip.current) > 0 ? azurerm_public_ip.current[0].ip_address : null
}
