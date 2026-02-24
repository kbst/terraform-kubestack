output "cluster" {
  value = aws_eks_cluster.current
}

output "current_config" {
  value = local.cfg
}

output "current_metadata" {
  value = module.cluster_metadata
}

output "kubeconfig" {
  value = local.kubeconfig
}
