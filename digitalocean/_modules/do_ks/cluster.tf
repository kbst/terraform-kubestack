resource "digitalocean_kubernetes_cluster" "current" {
  name    = "${var.metadata_name}"
  region  = "${var.region}"
  version = "${var.cluster_min_master_version}"

  node_pool {
    name       = "worker-pool"
    size       = "${var.cluster_machine_type}"
    node_count = "${var.initial_node_count}"
    tags       = "${var.metadata_tags}"
  }
}

data "digitalocean_kubernetes_cluster" "current" {
  name = "${digitalocean_kubernetes_cluster.current.name}"
}
