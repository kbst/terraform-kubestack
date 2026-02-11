resource "google_compute_network" "current" {
  name                    = module.cluster_metadata.name
  project                 = local.project_id
  auto_create_subnetworks = "true"
}

resource "google_compute_address" "nat" {
  count = local.enable_cloud_nat ? local.cloud_nat_ip_count : 0

  region  = google_container_cluster.current.location
  project = local.project_id

  name = "nat-${module.cluster_metadata.name}-${count.index}"
}

resource "google_compute_router" "current" {
  count = local.enable_cloud_nat ? 1 : 0

  project = local.project_id
  name    = module.cluster_metadata.name
  region  = google_container_cluster.current.location

  network = google_compute_network.current.name

  bgp {
    advertise_mode = (
      local.router_advertise_config_mode == null
      ? null
      : local.router_advertise_config_mode
    )
    advertised_groups = (
      local.router_advertise_config_mode == null ? null : (
        local.router_advertise_config_mode != "CUSTOM"
        ? null
        : local.router_advertise_config_groups
      )
    )
    dynamic "advertised_ip_ranges" {
      for_each = (
        local.router_advertise_config_mode == null ? {} : (
          local.router_advertise_config_mode != "CUSTOM"
          ? {}
          : { for ip in local.router_advertise_config_ip_ranges : ip => null }
        )
      )
      iterator = range
      content {
        range       = range.key
        description = range.value
      }
    }

    # expected "bgp.0.asn" to be a RFC6996-compliant Local ASN:
    # must be either in the private ASN ranges: [64512..65534], [4200000000..4294967294];
    # or be the value of [16550]
    asn = local.router_asn != null ? local.router_asn : 16550
  }
}

resource "google_compute_router_nat" "nat" {
  count = local.enable_cloud_nat ? 1 : 0

  project = local.project_id
  name    = module.cluster_metadata.name
  region  = google_compute_router.current[0].region
  router  = google_compute_router.current[0].name

  enable_endpoint_independent_mapping = local.cloud_nat_endpoint_independent_mapping
  min_ports_per_vm                    = local.cloud_nat_min_ports_per_vm
  nat_ip_allocate_option              = local.cloud_nat_ip_count > 0 ? "MANUAL_ONLY" : "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat  = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  nat_ips                             = local.cloud_nat_ip_count > 0 ? google_compute_address.nat.*.self_link : null

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
