module "cluster_services" {
  source = "../../../common/cluster_services"

  manifest_path = var.manifest_path

  template_string = kind_cluster.current.kubeconfig

  template_vars = {
    # hack, because modules can't have depends_on
    # enforcing node pools to be _created before_
    # and _destroyed after_ the cluster services
    # to prevent namespace getting stuck in terminating
    # during destroy
    not_used = kind_cluster.current.name
  }
}
