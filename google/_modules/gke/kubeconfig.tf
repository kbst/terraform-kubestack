locals {
  template_vars = {
    cluster_name     = google_container_cluster.current.name
    cluster_endpoint = google_container_cluster.current.endpoint
    cluster_ca       = google_container_cluster.current.master_auth[0].cluster_ca_certificate
    token            = data.google_client_config.default.access_token
  }

  kubeconfig = templatefile("${path.module}/templates/kubeconfig.tpl", local.template_vars)
}
