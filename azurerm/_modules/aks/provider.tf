provider "kubernetes" {
  alias = "aks"

  load_config_file = false

  host = azurerm_kubernetes_cluster.current.kube_config[0].host
  client_certificate = base64decode(
    azurerm_kubernetes_cluster.current.kube_config[0].client_certificate,
  )
  client_key = base64decode(azurerm_kubernetes_cluster.current.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(
    azurerm_kubernetes_cluster.current.kube_config[0].cluster_ca_certificate,
  )
}

