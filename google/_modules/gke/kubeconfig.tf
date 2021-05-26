data "template_file" "kubeconfig" {
  template = file("${path.module}/templates/kubeconfig.tpl")

  vars = {
    cluster_name     = google_container_cluster.current.name
    cluster_endpoint = google_container_cluster.current.endpoint
    cluster_ca       = google_container_cluster.current.master_auth[0].cluster_ca_certificate
    path_cwd         = path.cwd
  }

  # when the node pool is destroyed before the k8s namespaces
  # the namespaces get stuck in terminating
  depends_on = [module.node_pool]
}
