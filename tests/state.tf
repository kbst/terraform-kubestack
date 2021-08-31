terraform {
  backend "gcs" {
    bucket = "terraform-kubestack-testing-state"
  }
}

data "terraform_remote_state" "current" {
  backend = "gcs"
  config = {
    bucket = "terraform-kubestack-testing-state"
  }
  workspace = terraform.workspace

  defaults = {
    aks_zero_kubeconfig = module.aks_zero.kubeconfig_dummy
    eks_zero_kubeconfig = module.eks_zero.kubeconfig_dummy
    gke_zero_kubeconfig = module.gke_zero.kubeconfig_dummy
  }
}
