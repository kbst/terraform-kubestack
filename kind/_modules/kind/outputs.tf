output "kubeconfig" {
  sensitive = true
  value     = kind_cluster.current.kubeconfig
}
