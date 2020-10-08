output "aks_vnet" {
  value = module.cluster.aks_vnet
}
output "current_configuration" {
  value = module.configuration.merged["${terraform.workspace}"]
}
