module "kubeconfig" {
  source = "../../../common/kubeconfig"

  metadata_fqdn = "${var.metadata_fqdn}"

  template_string = "${file("${path.module}/templates/kubeconfig.tpl")}"

  template_vars = {
    cluster_name     = "${google_container_cluster.current.name}"
    cluster_endpoint = "${google_container_cluster.current.endpoint}"
    cluster_ca       = "${google_container_cluster.current.master_auth.0.cluster_ca_certificate}"
    path_cwd         = "${path.cwd}"
  }
}
