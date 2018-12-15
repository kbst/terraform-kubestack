module "kubeconfig" {
  source = "../../../common/kubeconfig"

  metadata_fqdn = "${var.metadata_fqdn}"

  template_string = "${file("${path.module}/templates/kubeconfig.tpl")}"

  template_vars = {
    cluster_name     = "${aws_eks_cluster.current.name}"
    cluster_endpoint = "${aws_eks_cluster.current.endpoint}"
    cluster_ca       = "${aws_eks_cluster.current.certificate_authority.0.data}"
  }
}
