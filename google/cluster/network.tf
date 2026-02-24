resource "google_compute_network" "current" {
  name                    = module.cluster_metadata.name
  project                 = local.cfg.project_id
  auto_create_subnetworks = true
}

resource "google_compute_address" "nat" {
  count = try(coalesce(local.cfg.enable_cloud_nat, null), true) ? try(coalesce(local.cfg.cloud_nat_ip_count, null), 0) : 0

  region  = google_container_cluster.current.location
  project = local.cfg.project_id

  name = "nat-${module.cluster_metadata.name}-${count.index}"
}

resource "google_compute_router" "current" {
  count = try(coalesce(local.cfg.enable_cloud_nat, null), true) ? 1 : 0

  project = local.cfg.project_id
  name    = module.cluster_metadata.name
  region  = google_container_cluster.current.location

  network = google_compute_network.current.name

  bgp {
    advertise_mode = (
      local.cfg.router_advertise_config == null
      ? null
      : local.cfg.router_advertise_config.mode
    )
    advertised_groups = (
      local.cfg.router_advertise_config == null ? null : (
        local.cfg.router_advertise_config.mode != "CUSTOM"
        ? null
        : try(coalesce(local.cfg.router_advertise_config.groups, null), toset([]))
      )
    )
    dynamic "advertised_ip_ranges" {
      for_each = (
        local.cfg.router_advertise_config == null ? [] : (
          local.cfg.router_advertise_config.mode != "CUSTOM"
          ? []
          : try(coalesce(local.cfg.router_advertise_config.ip_ranges, null), tomap({}))
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
    asn = local.cfg.router_asn != null ? local.cfg.router_asn : 16550
  }
}

resource "google_compute_router_nat" "nat" {
  count = try(coalesce(local.cfg.enable_cloud_nat, null), true) ? 1 : 0

  project = local.cfg.project_id
  name    = module.cluster_metadata.name
  region  = google_compute_router.current[0].region
  router  = google_compute_router.current[0].name

  enable_endpoint_independent_mapping = local.cfg.cloud_nat_enable_endpoint_independent_mapping
  min_ports_per_vm                    = local.cfg.cloud_nat_min_ports_per_vm
  nat_ip_allocate_option              = try(coalesce(local.cfg.cloud_nat_ip_count, null), 0) > 0 ? "MANUAL_ONLY" : "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat  = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  nat_ips                             = try(coalesce(local.cfg.cloud_nat_ip_count, null), 0) > 0 ? google_compute_address.nat[*].self_link : null

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
