output "current_config" {
  value = module.configuration.merged[terraform.workspace]
}

output "current_metadata" {
  value = module.cluster_metadata
}

output "kubeconfig" {
  value = local.kubeconfig

  # when the node pool is destroyed before the k8s namespaces
  # the namespaces get stuck in terminating
  depends_on = [module.node_pool]
}

output "default_ingress_ip" {
  value = length(google_compute_address.current) > 0 ? google_compute_address.current[0].address : null
}
