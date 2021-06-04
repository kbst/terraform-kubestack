provider "aws" {
  alias  = "eks_zero"
  region = "eu-west-1"
}


provider "kustomization" {
  alias          = "eks_zero"
  kubeconfig_raw = module.eks_zero.kubeconfig
}

locals {
  eks_zero_kubeconfig = yamldecode(module.eks_zero.kubeconfig)
}

provider "kubernetes" {
  alias = "eks_zero"

  host                   = local.eks_zero_kubeconfig["clusters"][0]["cluster"]["server"]
  cluster_ca_certificate = base64decode(local.eks_zero_kubeconfig["clusters"][0]["cluster"]["certificate-authority-data"])

  exec {
    api_version = local.eks_zero_kubeconfig["users"][0]["user"]["exec"]["apiVersion"]
    args        = local.eks_zero_kubeconfig["users"][0]["user"]["exec"]["args"]
    command     = local.eks_zero_kubeconfig["users"][0]["user"]["exec"]["command"]
  }
}
