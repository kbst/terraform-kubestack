output "aks_vnet" {
  value = module.cluster.aks_vnet
}

output "current_config" {
  value = module.configuration.merged[terraform.workspace]
}

output "kubeconfig" {
  sensitive = true
  value     = module.cluster.kubeconfig
}
