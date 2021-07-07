module "cluster_services" {
  source = "../../../common/cluster_services"

  cluster_type = "do_ks"

  metadata_labels = "${var.metadata_labels}"

  template_string = "${file("${path.module}/templates/kubeconfig.tpl")}"

  template_vars = {
    cluster_name     = "${data.digitalocean_kubernetes_cluster.current.name}"
    cluster_endpoint = "${data.digitalocean_kubernetes_cluster.current.endpoint}"
    cluster_ca       = "${data.digitalocean_kubernetes_cluster.current.kube_config.0.cluster_ca_certificate}"
    path_cwd         = "${path.cwd}"
  }
}
