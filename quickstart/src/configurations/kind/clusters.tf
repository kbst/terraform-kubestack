module "kind_zero" {
  source = "github.com/kbst/terraform-kubestack//kind/cluster?ref={{version}}"

  configuration = var.clusters["kind_zero"]
}
