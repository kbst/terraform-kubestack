provider "kustomization" {
  alias          = "gke_zero"
  kubeconfig_raw = module.gke_zero.kubeconfig
}

provider "kubernetes" {
  alias = "gke_zero"

  host                   = local.gke_zero_kubeconfig["clusters"][0]["cluster"]["server"]
  cluster_ca_certificate = base64decode(local.gke_zero_kubeconfig["clusters"][0]["cluster"]["certificate-authority-data"])
  token                  = local.gke_zero_kubeconfig["users"][0]["user"]["token"]
}
