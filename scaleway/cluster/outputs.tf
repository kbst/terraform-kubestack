output "cluster" {
  value = scaleway_k8s_cluster.current
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

  # The cluster kubeconfig is available immediately after cluster creation, but
  # the API server DNS entry is not ready until at least one node pool exists.
  depends_on = [module.node_pool]
}
