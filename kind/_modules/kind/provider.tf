data "external" "kind_kubeconfig" {
  program = ["sh", "${path.module}/provider_authenticator.sh"]

  query {
    cluster_name = "${var.metadata_name}"
  }
}

provider "kubernetes" {
  alias = "kind"

  config_path = "${data.external.kind_kubeconfig.result["kubeconfig_path"]}"
}
