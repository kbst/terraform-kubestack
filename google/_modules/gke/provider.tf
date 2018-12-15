data "google_client_config" "default" {}

provider "kubernetes" {
  alias = "gke"

  #config_path = "${local.cluster_dir}/kubeconfig"
  host                   = "https://${google_container_cluster.current.endpoint}"
  cluster_ca_certificate = "${base64decode(google_container_cluster.current.master_auth.0.cluster_ca_certificate)}"
  token                  = "${data.google_client_config.default.access_token}"
}
