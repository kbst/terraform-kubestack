variable "configuration" {
  type = map(object({
    # Required attributes
    name_prefix                = optional(string)
    base_domain                = optional(string)
    project_id                 = optional(string)
    region                     = optional(string)
    cluster_min_master_version = optional(string)

    # Optional attributes without defaults
    deletion_protection = optional(bool)

    cluster_node_locations = optional(list(string))

    cluster_release_channel = optional(string)

    cluster_daily_maintenance_window_start_time = optional(string)

    cluster_maintenance_exclusion = optional(object({
      start_time = optional(string)
      end_time   = optional(string)
      name       = optional(string)
      scope      = optional(string)
    }))

    default_node_pool = optional(object({
      remove_default_node_pool = optional(bool)
      initial_node_count       = optional(number)
      min_node_count           = optional(number)
      max_node_count           = optional(number)
      node_location_policy     = optional(string)
      extra_oauth_scopes       = optional(list(string))
      disk_size_gb             = optional(number)
      disk_type                = optional(string)
      image_type               = optional(string)
      machine_type             = optional(string)
      preemptible              = optional(bool)
      auto_repair              = optional(bool)
      auto_upgrade             = optional(bool)
      taints = optional(set(object({
        key    = string
        value  = string
        effect = string
      })))
      labels        = optional(map(string))
      instance_tags = optional(list(string))
      ephemeral_storage_local_ssd_config = optional(object({
        local_ssd_count = number
      }))
      network_config = optional(object({
        enable_private_nodes = bool
        create_pod_range     = bool
        pod_ipv4_cidr_block  = string
      }))
    }))

    disable_default_ingress = optional(bool)

    enable_private_nodes    = optional(bool)
    enable_private_endpoint = optional(bool)
    master_cidr_block       = optional(string)

    cluster_ipv4_cidr_block  = optional(string)
    services_ipv4_cidr_block = optional(string)

    cluster_database_encryption_key_name = optional(string)

    enable_cloud_nat                              = optional(bool)
    cloud_nat_enable_endpoint_independent_mapping = optional(bool)
    cloud_nat_min_ports_per_vm                    = optional(number)
    cloud_nat_ip_count                            = optional(number)

    disable_workload_identity     = optional(bool)
    node_workload_metadata_config = optional(string)

    master_authorized_networks_config_cidr_blocks = optional(set(string))

    enable_intranode_visibility = optional(bool)
    enable_tpu                  = optional(bool)

    router_advertise_config = optional(object({
      groups    = optional(set(string))
      ip_ranges = optional(map(string))
      mode      = optional(string)
    }))
    router_asn = optional(number)

    logging_config = optional(object({
      enable_components = optional(list(string))
    }))

    monitoring_config = optional(object({
      enable_components = optional(list(string))
    }))

    enable_gcs_fuse_csi_driver = optional(bool)
  }))

  description = "Map with per workspace cluster configuration."
  nullable    = false
}

variable "configuration_base_key" {
  type        = string
  description = "The key in the configuration map all other keys inherit from."
  default     = "apps"
  nullable    = false
}
