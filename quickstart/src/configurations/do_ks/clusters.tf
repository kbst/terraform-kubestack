module "do_zero" {
  source = "github.com/kbst/terraform-kubestack//digitalocean/cluster?ref={{version}}"
  configuration = "${var.clusters["do_ks_zero"]}"
}
