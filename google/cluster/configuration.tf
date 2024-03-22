module "configuration" {
  source = "../../common/configuration"

  configuration = var.configuration
  base_key      = var.configuration_base_key
}

locals {
  # current workspace config
  cfg = module.configuration.merged[terraform.workspace]

  name_prefix = local.cfg["name_prefix"]

  base_domain = local.cfg["base_domain"]

  project_id = local.cfg["project_id"]

  region = local.cfg["region"]

  deletion_protection = lookup(local.cfg, "deletion_protection", null)

  cluster_node_locations_lookup = lookup(local.cfg, "cluster_node_locations", "")
  cluster_node_locations        = split(",", local.cluster_node_locations_lookup)

  cluster_min_master_version = local.cfg["cluster_min_master_version"]
  cluster_release_channel    = lookup(local.cfg, "cluster_release_channel", "STABLE")

  cluster_daily_maintenance_window_start_time = lookup(
    local.cfg,
    "cluster_daily_maintenance_window_start_time",
    "03:00",
  )

  cluster_maintenance_exclusion_start_time = lookup(local.cfg, "cluster_maintenance_exclusion_start_time", "")
  cluster_maintenance_exclusion_end_time = lookup(local.cfg, "cluster_maintenance_exclusion_end_time", "")
  cluster_maintenance_exclusion_name = lookup(local.cfg, "cluster_maintenance_exclusion_name", "")
  cluster_maintenance_exclusion_scope = lookup(local.cfg, "cluster_maintenance_exclusion_scope", "")

  remove_default_node_pool = lookup(local.cfg, "remove_default_node_pool", true)

  cluster_initial_node_count = lookup(local.cfg, "cluster_initial_node_count", 1)

  cluster_min_node_count       = lookup(local.cfg, "cluster_min_node_count", 1)
  cluster_max_node_count       = lookup(local.cfg, "cluster_max_node_count", 1)
  cluster_node_location_policy = lookup(local.cfg, "cluster_node_location_policy", null)

  cluster_extra_oauth_scopes_lookup = lookup(local.cfg, "cluster_extra_oauth_scopes", "")
  cluster_extra_oauth_scopes        = split(",", local.cluster_extra_oauth_scopes_lookup)

  cluster_disk_size_gb = lookup(local.cfg, "cluster_disk_size_gb", 100)

  cluster_disk_type = lookup(local.cfg, "cluster_disk_type", "pd-standard")

  cluster_image_type = lookup(local.cfg, "cluster_image_type", null)

  cluster_machine_type = lookup(local.cfg, "cluster_machine_type", "")

  cluster_preemptible = lookup(local.cfg, "cluster_preemptible", false)

  cluster_auto_repair = lookup(local.cfg, "cluster_auto_repair", true)

  cluster_auto_upgrade = lookup(local.cfg, "cluster_auto_upgrade", true)

  disable_default_ingress = lookup(local.cfg, "disable_default_ingress", false)

  enable_private_nodes = lookup(local.cfg, "enable_private_nodes", true)
  master_cidr_block    = lookup(local.cfg, "master_cidr_block", "172.16.0.32/28")

  cluster_ipv4_cidr_block  = lookup(local.cfg, "cluster_ipv4_cidr_block", null)
  services_ipv4_cidr_block = lookup(local.cfg, "services_ipv4_cidr_block", null)

  cluster_database_encryption_key_name = lookup(local.cfg, "cluster_database_encryption_key_name", null)

  # by default include cloud_nat when private nodes are enabled
  enable_cloud_nat                       = lookup(local.cfg, "enable_cloud_nat", local.enable_private_nodes)
  cloud_nat_endpoint_independent_mapping = lookup(local.cfg, "cloud_nat_enable_endpoint_independent_mapping", null)
  cloud_nat_min_ports_per_vm             = lookup(local.cfg, "cloud_nat_min_ports_per_vm", null)
  cloud_nat_ip_count                     = lookup(local.cfg, "cloud_nat_ip_count", 0)

  disable_workload_identity             = lookup(local.cfg, "disable_workload_identity", false)
  default_node_workload_metadata_config = tobool(local.disable_workload_identity) == false ? "GKE_METADATA" : "MODE_UNSPECIFIED"
  node_workload_metadata_config         = lookup(local.cfg, "node_workload_metadata_config", local.default_node_workload_metadata_config)

  master_authorized_networks_config_cidr_blocks_lookup = lookup(local.cfg, "master_authorized_networks_config_cidr_blocks", null)
  master_authorized_networks_config_cidr_blocks        = local.master_authorized_networks_config_cidr_blocks_lookup == null ? null : split(",", local.master_authorized_networks_config_cidr_blocks_lookup)

  enable_intranode_visibility = lookup(local.cfg, "enable_intranode_visibility", false)
  enable_tpu                  = lookup(local.cfg, "enable_tpu", false)

  router_advertise_config_groups_lookup    = lookup(local.cfg, "router_advertise_config_groups", "")
  router_advertise_config_groups           = compact(split(",", local.router_advertise_config_groups_lookup))
  router_advertise_config_ip_ranges_lookup = lookup(local.cfg, "router_advertise_config_ip_ranges", "")
  router_advertise_config_ip_ranges        = compact(split(",", local.router_advertise_config_ip_ranges_lookup))
  router_advertise_config_mode             = lookup(local.cfg, "router_advertise_config_mode", null)
  router_asn                               = lookup(local.cfg, "router_asn", null)

  logging_config_enable_components_lookup = lookup(local.cfg, "logging_config_enable_components", "SYSTEM_COMPONENTS,WORKLOADS")
  logging_config_enable_components        = compact(split(",", local.logging_config_enable_components_lookup))

  monitoring_config_enable_components_lookup = lookup(local.cfg, "monitoring_config_enable_components", "SYSTEM_COMPONENTS")
  monitoring_config_enable_components        = compact(split(",", local.monitoring_config_enable_components_lookup))

  enable_gcs_fuse_csi_driver = lookup(local.cfg, "enable_gcs_fuse_csi_driver", null)
}
