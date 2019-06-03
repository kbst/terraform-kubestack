data "local_file" "kubeconfig" {
  filename = "${data.external.kind_kubeconfig.result["kubeconfig_path"]}"

  depends_on = ["null_resource.cluster"]
}

module "cluster_services" {
  source = "../../../common/cluster_services"

  cluster_type = "kind"

  metadata_labels = "${var.metadata_labels}"

  template_string = "${data.local_file.kubeconfig.content}"

  template_vars = {
    # hack, because modules can't have depends_on
    # prevent a race between kubernetes provider and cluster services/kustomize
    # creating the namespace and the provider erroring out during apply
    not_used = "${kubernetes_namespace.current.metadata.0.name}"
  }
}
