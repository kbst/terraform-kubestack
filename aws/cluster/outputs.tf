output "current_config" {
  value = module.configuration.merged[terraform.workspace]
}

output "kubeconfig" {
  sensitive = true
  value     = module.cluster.kubeconfig
}
