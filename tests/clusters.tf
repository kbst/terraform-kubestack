module "eks_zero" {
  providers = {
    aws = "aws.eks_zero"
  }

  source = "../aws/cluster"

  configuration = "${var.clusters["eks_zero"]}"
}

module "gke_zero" {
  source = "../google/cluster"

  configuration = "${var.clusters["gke_zero"]}"
}

module "aks_zero" {
  source = "../azurerm/cluster"

  configuration = "${var.clusters["aks_zero"]}"
}
