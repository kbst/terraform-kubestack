provider "kubernetes" {
  alias                  = "do_ks"
  host                   = "${digitalocean_kubernetes_cluster.current.endpoint}"
  client_certificate     = "${base64decode(digitalocean_kubernetes_cluster.current.kube_config.0.client_certificate)}"
  cluster_ca_certificate = "${base64decode(digitalocean_kubernetes_cluster.current.kube_config.0.cluster_ca_certificate)}"
  client_key             = "${base64decode(digitalocean_kubernetes_cluster.current.kube_config.0.client_key)}"
}
