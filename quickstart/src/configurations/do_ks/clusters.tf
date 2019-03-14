module "do_zero" {
  source = "../../../../digitalocean/cluster"
  configuration = "${var.clusters["do_ks_zero"]}"
}
