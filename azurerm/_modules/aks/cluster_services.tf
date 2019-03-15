module "cluster_services" {
  source = "../../../common/cluster_services"

  cluster_type = "aks"

  metadata_labels = "${var.metadata_labels}"
  label_namespace = "${var.metadata_label_namespace}"

  template_string = "${file("${path.module}/templates/kubeconfig.tpl")}"

  template_vars = {
    cluster_name     = "${azurerm_kubernetes_cluster.current.name}"
    cluster_endpoint = "${azurerm_kubernetes_cluster.current.kube_config.0.host}"
    cluster_ca       = "${azurerm_kubernetes_cluster.current.kube_config.0.cluster_ca_certificate}"
    client_cert      = "${azurerm_kubernetes_cluster.current.kube_config.0.client_certificate}"
    client_key       = "${azurerm_kubernetes_cluster.current.kube_config.0.client_key}"
    path_cwd         = "${path.cwd}"
  }
}
