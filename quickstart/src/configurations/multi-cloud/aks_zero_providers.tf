provider "azurerm" {
  features {}
}

provider "kustomization" {
  alias          = "aks_zero"
  kubeconfig_raw = module.aks_zero.kubeconfig
}
