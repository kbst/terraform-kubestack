resource "google_compute_network" "current" {
  name                    = var.metadata_name
  project                 = var.project
  auto_create_subnetworks = "true"
}

resource "google_compute_address" "nat" {
  count = var.enable_cloud_nat ? var.cloud_nat_ip_count : 0

  region  = google_container_cluster.current.location
  project = var.project

  name = "nat-${var.metadata_name}-${count.index}"
}

resource "google_compute_router" "current" {
  count = var.enable_cloud_nat ? 1 : 0

  project = var.project
  name    = var.metadata_name
  region  = google_container_cluster.current.location

  network = google_compute_network.current.name

  bgp {
    advertise_mode = (
      var.router_advertise_config == null
      ? null
      : var.router_advertise_config.mode
    )
    advertised_groups = (
      var.router_advertise_config == null ? null : (
        var.router_advertise_config.mode != "CUSTOM"
        ? null
        : var.router_advertise_config.groups
      )
    )
    dynamic "advertised_ip_ranges" {
      for_each = (
        var.router_advertise_config == null ? {} : (
          var.router_advertise_config.mode != "CUSTOM"
          ? {}
          : var.router_advertise_config.ip_ranges
        )
      )
      iterator = range
      content {
        range       = range.key
        description = range.value
      }
    }
    asn = var.router_asn
  }
}

resource "google_compute_router_nat" "nat" {
  count = var.enable_cloud_nat ? 1 : 0

  project = var.project
  name    = var.metadata_name
  region  = google_compute_router.current[0].region
  router  = google_compute_router.current[0].name

  enable_endpoint_independent_mapping = var.cloud_nat_endpoint_independent_mapping
  min_ports_per_vm                    = var.cloud_nat_min_ports_per_vm
  nat_ip_allocate_option              = var.cloud_nat_ip_count > 0 ? "MANUAL_ONLY" : "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat  = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  nat_ips                             = var.cloud_nat_ip_count > 0 ? google_compute_address.nat.*.self_link : null

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
