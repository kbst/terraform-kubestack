locals {
  template_vars = {
    cluster_name     = aws_eks_cluster.current.name
    cluster_endpoint = aws_eks_cluster.current.endpoint
    cluster_ca       = aws_eks_cluster.current.certificate_authority[0].data
    token            = nonsensitive(data.aws_eks_cluster_auth.current.token)
  }

  kubeconfig = templatefile("${path.module}/templates/kubeconfig.tpl", local.template_vars)
}
