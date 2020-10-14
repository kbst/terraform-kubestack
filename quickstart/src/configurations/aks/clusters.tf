module "aks_zero" {
  source = "github.com/kbst/terraform-kubestack//azurerm/cluster?ref={{version}}"

  configuration = var.clusters["aks_zero"]

  # vnet_subnet_id = azurerm_subnet.external.id  # uncomment and populate with an externally-created
                                                 # subnet's ID when using CNI/advanced networking
}
