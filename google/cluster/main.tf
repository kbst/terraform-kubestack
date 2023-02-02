module "cluster_metadata" {
  source = "../../common/metadata"

  name_prefix = local.cfg["name_prefix"]
  base_domain = local.cfg["base_domain"]

  provider_name   = "gcp"
  provider_region = local.cfg["region"]
}

module "cluster" {
  source = "../_modules/gke"

  project = local.cfg["project_id"]

  metadata_name   = module.cluster_metadata.name
  metadata_fqdn   = module.cluster_metadata.fqdn
  metadata_tags   = module.cluster_metadata.tags
  metadata_labels = module.cluster_metadata.labels

  location       = local.cfg["region"]
  node_locations = local.cfg["cluster_node_locations"]

  min_master_version = local.cfg["cluster_min_master_version"]

  daily_maintenance_window_start_time = local.cfg["cluster_daily_maintenance_window_start_time"] != null ? local.cfg["cluster_daily_maintenance_window_start_time"] : "03:00"

  remove_default_node_pool = local.cfg["remove_default_node_pool"] != null ? local.cfg["remove_default_node_pool"] : true

  initial_node_count = local.cfg["cluster_initial_node_count"] != null ? local.cfg["cluster_initial_node_count"] : 1
  min_node_count     = local.cfg["cluster_min_node_count"] != null ? local.cfg["cluster_min_node_count"] : 1
  max_node_count     = local.cfg["cluster_max_node_count"] != null ? local.cfg["cluster_max_node_count"] : 1
  location_policy    = local.cfg["cluster_node_location_policy"]

  extra_oauth_scopes = local.cfg["cluster_extra_oauth_scopes"]

  disk_size_gb = local.cfg["cluster_disk_size_gb"] != null ? local.cfg["cluster_disk_size_gb"] : 100
  disk_type    = local.cfg["cluster_disk_type"] != null ? local.cfg["cluster_disk_type"] : "pd-standard"
  image_type   = local.cfg["cluster_image_type"]
  machine_type = local.cfg["cluster_machine_type"]

  preemptible = local.cfg["cluster_preemptible"] != null ? local.cfg["cluster_preemptible"] : false

  auto_repair  = local.cfg["cluster_auto_repair"] != null ? local.cfg["cluster_auto_repair"] : true
  auto_upgrade = local.cfg["cluster_auto_upgrade"] != null ? local.cfg["cluster_auto_upgrade"] : true

  disable_default_ingress = local.cfg["disable_default_ingress"] != null ? local.cfg["disable_default_ingress"] : false

  enable_private_nodes     = local.cfg["enable_private_nodes"] != null ? local.cfg["enable_private_nodes"] : true
  master_cidr_block        = local.cfg["master_cidr_block"] != null ? local.cfg["master_cidr_block"] : "172.16.0.32/28"
  cluster_ipv4_cidr_block  = local.cfg["cluster_ipv4_cidr_block"]
  services_ipv4_cidr_block = local.cfg["services_ipv4_cidr_block"]

  # by default include cloud_nat when private nodes are enabled
  enable_cloud_nat                       = local.cfg["enable_cloud_nat"] != null ? local.cfg["enable_cloud_nat"] : local.cfg["enable_private_nodes"] != null ? local.cfg["enable_private_nodes"] : true
  cloud_nat_endpoint_independent_mapping = local.cfg["cloud_nat_endpoint_independent_mapping"]
  cloud_nat_min_ports_per_vm             = local.cfg["cloud_nat_min_ports_per_vm"]
  cloud_nat_ip_count                     = local.cfg["cloud_nat_ip_count"] != null ? local.cfg["cloud_nat_ip_count"] : 0

  master_authorized_networks_config_cidr_blocks = local.cfg["master_authorized_networks_config_cidr_blocks"]

  disable_workload_identity     = local.cfg["disable_workload_identity"] != null ? local.cfg["disable_workload_identity"] : false
  node_workload_metadata_config = local.cfg["node_workload_metadata_config"] != null ? local.cfg["node_workload_metadata_config"] : local.cfg["disable_workload_identity"] != true ? "GKE_METADATA" : "MODE_UNSPECIFIED"

  cluster_database_encryption_key_name = local.cfg["cluster_database_encryption_key_name"]

  enable_intranode_visibility = local.cfg["enable_intranode_visibility"] != null ? local.cfg["enable_intranode_visibility"] : false
  enable_tpu                  = local.cfg["enable_tpu"] != null ? local.cfg["enable_tpu"] : false

  router_advertise_config = local.cfg["router_advertise_config"] != null ? {
    groups    = local.cfg.router_advertise_config["groups"]
    ip_ranges = { for ip in local.cfg.router_advertise_config["ip_ranges"] : ip => null }
    mode      = local.cfg.router_advertise_config["mode"]
  } : null
  router_asn = local.cfg["router_asn"]

  logging_config_enable_components    = local.cfg["logging_config_enable_components"] != null ? local.cfg["logging_config_enable_components"] : ["SYSTEM_COMPONENTS", "WORKLOADS"]
  monitoring_config_enable_components = local.cfg["monitoring_config_enable_components"] != null ? local.cfg["monitoring_config_enable_components"] : ["SYSTEM_COMPONENTS"]

  enable_gcs_fuse_csi_driver = local.cfg["enable_gcs_fuse_csi_driver"] != null ? local.cfg["monitoring_config_enable_components"] : false
}
