module "cluster_services" {
  source = "../../../common/cluster_services"

  template_string = file("${path.module}/templates/kubeconfig.tpl")

  template_vars = {
    cluster_name       = aws_eks_cluster.current.name
    cluster_endpoint   = aws_eks_cluster.current.endpoint
    cluster_ca         = aws_eks_cluster.current.certificate_authority[0].data
    caller_id_arn      = local.caller_id_arn
    caller_id_arn_type = local.caller_id_arn_type
  }
}
