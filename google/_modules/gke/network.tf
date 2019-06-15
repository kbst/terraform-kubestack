resource "google_compute_network" "current" {
  name                    = var.metadata_name
  project                 = var.project
  auto_create_subnetworks = "true"
}

