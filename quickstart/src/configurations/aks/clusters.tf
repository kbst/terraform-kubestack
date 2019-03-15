module "aks_zero" {
  source = "github.com/kbst/terraform-kubestack//azurerm/cluster?ref={{version}}"

  configuration = "${var.clusters["aks_zero"]}"
}
