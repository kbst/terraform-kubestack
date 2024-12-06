module "cluster_metadata" {
  source = "../../common/metadata"

  name_prefix = local.name_prefix
  base_domain = local.base_domain

  provider_name   = "gcp"
  provider_region = local.region
}

module "cluster" {
  source = "../_modules/gke"

  project = local.project_id

  deletion_protection = local.deletion_protection

  metadata_name   = module.cluster_metadata.name
  metadata_fqdn   = module.cluster_metadata.fqdn
  metadata_tags   = module.cluster_metadata.tags
  metadata_labels = module.cluster_metadata.labels

  location       = local.region
  node_locations = local.cluster_node_locations

  min_master_version = local.cluster_min_master_version
  release_channel    = local.cluster_release_channel

  daily_maintenance_window_start_time = local.cluster_daily_maintenance_window_start_time

  maintenance_exclusion_start_time = local.cluster_maintenance_exclusion_start_time
  maintenance_exclusion_end_time = local.cluster_maintenance_exclusion_end_time
  maintenance_exclusion_name = local.cluster_maintenance_exclusion_name
  maintenance_exclusion_scope = local.cluster_maintenance_exclusion_scope

  remove_default_node_pool = local.remove_default_node_pool

  initial_node_count = local.cluster_initial_node_count
  min_node_count     = local.cluster_min_node_count
  max_node_count     = local.cluster_max_node_count
  location_policy    = local.cluster_node_location_policy

  extra_oauth_scopes = local.cluster_extra_oauth_scopes

  disk_size_gb = local.cluster_disk_size_gb
  disk_type    = local.cluster_disk_type
  image_type   = local.cluster_image_type
  machine_type = local.cluster_machine_type

  preemptible = local.cluster_preemptible

  auto_repair = local.cluster_auto_repair

  auto_upgrade = local.cluster_auto_upgrade

  disable_default_ingress = local.disable_default_ingress

  enable_private_nodes = local.enable_private_nodes
  master_cidr_block    = local.master_cidr_block

  cluster_ipv4_cidr_block  = local.cluster_ipv4_cidr_block
  services_ipv4_cidr_block = local.services_ipv4_cidr_block

  enable_cloud_nat                       = local.enable_cloud_nat
  cloud_nat_endpoint_independent_mapping = local.cloud_nat_endpoint_independent_mapping
  cloud_nat_ip_count                     = local.cloud_nat_ip_count

  master_authorized_networks_config_cidr_blocks = local.master_authorized_networks_config_cidr_blocks

  cloud_nat_min_ports_per_vm = local.cloud_nat_min_ports_per_vm

  disable_workload_identity     = local.disable_workload_identity
  node_workload_metadata_config = local.node_workload_metadata_config

  cluster_database_encryption_key_name = local.cluster_database_encryption_key_name

  enable_intranode_visibility = local.enable_intranode_visibility
  enable_tpu                  = local.enable_tpu

  router_advertise_config = {
    groups    = local.router_advertise_config_groups
    ip_ranges = { for ip in local.router_advertise_config_ip_ranges : ip => null }
    mode      = local.router_advertise_config_mode
  }
  router_asn = local.router_asn

  logging_config_enable_components    = local.logging_config_enable_components
  monitoring_config_enable_components = local.monitoring_config_enable_components

  enable_gcs_fuse_csi_driver = local.enable_gcs_fuse_csi_driver
}
