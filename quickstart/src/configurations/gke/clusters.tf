module "gke_zero" {
  source = "github.com/kbst/terraform-kubestack//google/cluster?ref={{version}}"

  configuration = "${var.clusters["gke_zero"]}"
}
