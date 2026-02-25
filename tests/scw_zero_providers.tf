provider "scaleway" {
  region = "fr-par"
}

provider "kustomization" {
  alias          = "scw_zero"
  kubeconfig_raw = module.scw_zero.kubeconfig
}

locals {
  scw_zero_kubeconfig = yamldecode(module.scw_zero.kubeconfig)
}

provider "kubernetes" {
  alias = "scw_zero"

  host  = local.scw_zero_kubeconfig["clusters"][0]["cluster"]["server"]
  token = local.scw_zero_kubeconfig["users"][0]["user"]["token"]
  cluster_ca_certificate = base64decode(
    local.scw_zero_kubeconfig["clusters"][0]["cluster"]["certificate-authority-data"]
  )
}
