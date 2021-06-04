data "template_file" "kubeconfig" {
  template = file("${path.module}/templates/kubeconfig.tpl")

  vars = {
    cluster_name     = azurerm_kubernetes_cluster.current.name
    cluster_endpoint = azurerm_kubernetes_cluster.current.kube_config[0].host
    cluster_ca       = azurerm_kubernetes_cluster.current.kube_config[0].cluster_ca_certificate
    client_cert      = azurerm_kubernetes_cluster.current.kube_config[0].client_certificate
    client_key       = azurerm_kubernetes_cluster.current.kube_config[0].client_key
    path_cwd         = path.cwd
  }
}
