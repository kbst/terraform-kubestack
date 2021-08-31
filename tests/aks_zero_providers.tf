provider "kustomization" {
  alias = "aks_zero"
  kubeconfig_raw = data.terraform_remote_state.current.outputs.aks_zero_kubeconfig
}
