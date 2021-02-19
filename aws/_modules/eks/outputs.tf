output "kubeconfig" {
  sensitive = true
  value     = module.cluster_services.kubeconfig
}
