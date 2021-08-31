provider "kustomization" {
  alias          = "gke_zero"
  kubeconfig_raw = data.terraform_remote_state.current.outputs.gke_zero_kubeconfig
}

locals {
  gke_zero_kubeconfig = yamldecode(data.terraform_remote_state.current.outputs.gke_zero_kubeconfig)
}

provider "kubernetes" {
  alias = "gke_zero"

  host                   = local.gke_zero_kubeconfig["clusters"][0]["cluster"]["server"]
  cluster_ca_certificate = base64decode(local.gke_zero_kubeconfig["clusters"][0]["cluster"]["certificate-authority-data"])

  //token = local.gke_zero_kubeconfig["users"][0]["user"]["token"]

  exec {
    api_version = local.gke_zero_kubeconfig["users"][0]["user"]["exec"]["apiVersion"]
    command     = local.gke_zero_kubeconfig["users"][0]["user"]["exec"]["command"]
  }
}
