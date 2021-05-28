provider "kustomization" {
  alias          = "kind_zero"
  kubeconfig_raw = module.kind_zero.kubeconfig
}
