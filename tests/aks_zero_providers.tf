provider "azurerm" {
  alias = "aks_zero"

  features {}
}

provider "kustomization" {
  alias          = "aks_zero"
  kubeconfig_raw = module.aks_zero.kubeconfig
}

locals {
  aks_zero_kubeconfig = yamldecode(module.aks_zero.kubeconfig)
}

provider "kubernetes" {
  alias = "aks_zero"

  host                   = local.aks_zero_kubeconfig["clusters"][0]["cluster"]["server"]
  cluster_ca_certificate = base64decode(local.aks_zero_kubeconfig["clusters"][0]["cluster"]["certificate-authority-data"])
  client_certificate     = base64decode(local.aks_zero_kubeconfig["users"][0]["user"]["client-certificate-data"])
  client_key             = base64decode(local.aks_zero_kubeconfig["users"][0]["user"]["client-key-data"])
}
