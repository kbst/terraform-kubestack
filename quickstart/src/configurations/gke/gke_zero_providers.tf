provider "kustomization" {
  alias          = "gke_zero"
  kubeconfig_raw = module.gke_zero.kubeconfig
}
