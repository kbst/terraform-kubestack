resource "google_compute_network" "current" {
  name                    = var.metadata_name
  project                 = var.project
  auto_create_subnetworks = "true"
}

resource "google_compute_router" "current" {
  count = var.enable_cloud_nat ? 1 : 0

  project = var.project
  name    = var.metadata_name
  region  = google_container_cluster.current.location

  network = google_compute_network.current.name
}

resource "google_compute_router_nat" "nat" {
  count = var.enable_cloud_nat ? 1 : 0

  project = var.project
  name    = var.metadata_name
  region  = google_compute_router.current[0].region
  router  = google_compute_router.current[0].name

  enable_endpoint_independent_mapping = var.cloud_nat_endpoint_independent_mapping
  min_ports_per_vm                    = var.cloud_nat_min_ports_per_vm
  nat_ip_allocate_option              = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat  = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
