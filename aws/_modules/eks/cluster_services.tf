module "cluster_services" {
  source = "../../../common/cluster_services"

  cluster_type = "eks"

  metadata_labels = "${var.metadata_labels}"

  template_string = "${file("${path.module}/templates/kubeconfig.tpl")}"

  template_vars = {
    cluster_name     = "${aws_eks_cluster.current.name}"
    cluster_endpoint = "${aws_eks_cluster.current.endpoint}"
    cluster_ca       = "${aws_eks_cluster.current.certificate_authority.0.data}"
    role_arn         = "${data.aws_iam_role.kubestack_administrator.arn}"

    # hack, because modules can't have depends_on
    # prevent a race between kubernetes provider and cluster services/kustomize
    # creating the namespace and the provider erroring out during apply
    not_used = "${kubernetes_namespace.current.metadata.0.name}"
  }
}
