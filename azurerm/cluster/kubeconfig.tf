locals {
  kubeconfig = yamlencode({
    apiVersion = "v1"
    kind       = "Config"
    clusters = [
      {
        cluster = {
          server                     = azurerm_kubernetes_cluster.current.kube_config[0].host
          certificate-authority-data = azurerm_kubernetes_cluster.current.kube_config[0].cluster_ca_certificate
        }
        name = azurerm_kubernetes_cluster.current.name
      }
    ]
    users = [
      {
        user = {
          client-certificate-data = azurerm_kubernetes_cluster.current.kube_config[0].client_certificate
          client-key-data         = azurerm_kubernetes_cluster.current.kube_config[0].client_key
        }
        name = azurerm_kubernetes_cluster.current.name
      }
    ]
    contexts = [
      {
        context = {
          cluster = azurerm_kubernetes_cluster.current.name
          user    = azurerm_kubernetes_cluster.current.name
        }
        name = azurerm_kubernetes_cluster.current.name
      }
    ]
    current-context = azurerm_kubernetes_cluster.current.name
    preferences     = {}
  })
}
