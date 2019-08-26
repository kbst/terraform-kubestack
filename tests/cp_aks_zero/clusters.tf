module "aks_zero" {
  source = "../../azurerm/cluster"

  configuration = var.clusters["aks_zero"]
}
