module "cluster_services" {
  source = "../../../common/cluster_services"

  cluster_type = "gke"

  metadata_labels = var.metadata_labels

  template_string = file("${path.module}/templates/kubeconfig.tpl")

  template_vars = {
    cluster_name     = google_container_cluster.current.name
    cluster_endpoint = google_container_cluster.current.endpoint
    cluster_ca       = google_container_cluster.current.master_auth[0].cluster_ca_certificate
    path_cwd         = path.cwd
    # hack, because modules can't have depends_on
    # enforcing node pools to be _created before_
    # and _destroyed after_ the cluster services
    # to prevent namespace getting stuck in terminating
    # during destroy
    not_used = module.node_pool.id
  }
}
