provider "kind" {}

provider "kubernetes" {
  alias = "kind"

  config_path = kind.current.kubeconfig_path
}
