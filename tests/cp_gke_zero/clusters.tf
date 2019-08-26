module "gke_zero" {
  source = "../../google/cluster"

  configuration = var.clusters["gke_zero"]
}
