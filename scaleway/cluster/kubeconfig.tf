locals {
  kubeconfig = yamlencode({
    apiVersion = "v1"
    kind       = "Config"
    clusters = [
      {
        cluster = {
          server                     = scaleway_k8s_cluster.current.kubeconfig[0].host
          certificate-authority-data = scaleway_k8s_cluster.current.kubeconfig[0].cluster_ca_certificate
        }
        name = scaleway_k8s_cluster.current.name
      }
    ]
    users = [
      {
        user = {
          token = scaleway_k8s_cluster.current.kubeconfig[0].token
        }
        name = scaleway_k8s_cluster.current.name
      }
    ]
    contexts = [
      {
        context = {
          cluster = scaleway_k8s_cluster.current.name
          user    = scaleway_k8s_cluster.current.name
        }
        name = scaleway_k8s_cluster.current.name
      }
    ]
    current-context = scaleway_k8s_cluster.current.name
    preferences     = {}
  })
}
