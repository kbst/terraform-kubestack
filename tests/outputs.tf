output "aks_zero_kubeconfig" {
  value     = module.aks_zero.kubeconfig
  sensitive = true
}

output "eks_zero_kubeconfig" {
  value     = module.eks_zero.kubeconfig
  sensitive = true
}

output "gke_zero_kubeconfig" {
  value     = module.gke_zero.kubeconfig
  sensitive = true
}
