variable "configuration" {
  type = map(object({
    name_prefix = optional(string)
    base_domain = optional(string)

    project_id = optional(string)

    region = optional(string)

    cluster_node_locations = optional(list(string))

    cluster_min_master_version = optional(string)

    cluster_daily_maintenance_window_start_time = optional(string)

    remove_default_node_pool = optional(bool)

    cluster_machine_type = optional(string)
    cluster_image_type   = optional(string)

    cluster_disk_type            = optional(string)
    cluster_initial_node_count   = optional(number)
    cluster_min_node_count       = optional(number)
    cluster_max_node_count       = optional(number)
    cluster_node_location_policy = optional(string)

    cluster_disk_type    = optional(string)
    cluster_disk_size_gb = optional(number)

    cluster_preemptible  = optional(bool)
    cluster_auto_repair  = optional(bool)
    cluster_auto_upgrade = optional(bool)

    enable_private_nodes     = optional(bool)
    master_cidr_block        = optional(string)
    cluster_ipv4_cidr_block  = optional(string)
    services_ipv4_cidr_block = optional(string)

    enable_cloud_nat                       = optional(bool)
    cloud_nat_endpoint_independent_mapping = optional(string)
    cloud_nat_min_ports_per_vm             = optional(string)
    cloud_nat_ip_count                     = optional(string)

    master_authorized_networks_config_cidr_blocks = optional(list(string))

    router_advertise_config = optional(object({
      groups    = optional(list(string))
      ip_ranges = optional(list(string))
      mode      = optional(string)
    }))
    router_asn = optional(string)

    disable_workload_identity             = optional(bool)
    default_node_workload_metadata_config = optional(string)
    node_workload_metadata_config         = optional(string)

    enable_intranode_visibility = optional(bool)

    enable_tpu = optional(bool)

    cluster_extra_oauth_scopes = optional(list(string))

    cluster_database_encryption_key_name = optional(string)

    logging_config_enable_components    = optional(list(string))
    monitoring_config_enable_components = optional(list(string))

    disable_default_ingress = optional(bool)

    enable_gcs_fuse_csi_driver = optional(bool)
  }))
  description = "Map with per workspace cluster configuration."
}

variable "configuration_base_key" {
  type        = string
  description = "The key in the configuration map all other keys inherit from."
  default     = "apps"
}
