output "current_config" {
  value = module.configuration.merged[terraform.workspace]
}

output "current_metadata" {
  value = module.cluster_metadata
}

output "kubeconfig" {
  value = module.cluster.kubeconfig
}

output "default_ingress_ip" {
  # the cluster module returns an IP as a string
  # we YAML encode null for cluster-local to provide
  # a unified output to consumers
  value = yamlencode(null)
}
