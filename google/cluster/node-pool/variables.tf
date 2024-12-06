variable "configuration" {
  type = map(object({
    project_id = optional(string)

    name = optional(string)

    location        = optional(string)
    node_locations  = optional(list(string))
    location_policy = optional(string)

    initial_node_count = optional(string)
    min_node_count     = optional(string)
    max_node_count     = optional(string)

    disk_size_gb = optional(string)
    disk_type    = optional(string)
    image_type   = optional(string)
    machine_type = optional(string)

    preemptible  = optional(bool)
    auto_repair  = optional(bool)
    auto_upgrade = optional(bool)

    taints = optional(set(object({
      key    = string
      value  = string
      effect = string
    })))

    labels = optional(map(string))

    labels = optional(map(string))

    extra_oauth_scopes = optional(list(string))

    node_workload_metadata_config = optional(string)

    service_account_email = optional(string)

    ephemeral_storage_local_ssd_config = optional(object({
      local_ssd_count = number
    }))

    guest_accelerator = optional(object({
      type               = string
      count              = number
      gpu_partition_size = optional(string)
      gpu_sharing_config = optional(object({
        gpu_sharing_strategy       = optional(string)
        max_shared_clients_per_gpu = optional(number)
      }))
    }))

    network_config = optional(object({
      enable_private_nodes = bool
      create_pod_range     = bool
      pod_ipv4_cidr_block  = string
    }))

    instance_tags = optional(list(string))

    ephemeral_storage_local_ssd_config = optional(object({
      local_ssd_count = number
    }))

    guest_accelerator = optional(object({
      type               = string
      count              = number
      gpu_partition_size = optional(string)
      gpu_sharing_config = optional(object({
        gpu_sharing_strategy       = optional(string)
        max_shared_clients_per_gpu = optional(number)
      }))
    }))
  }))

  description = "Map with per workspace cluster configuration."
}

variable "configuration_base_key" {
  type        = string
  description = "The key in the configuration map all other keys inherit from."
  default     = "apps"
}

variable "cluster_metadata" {
  type        = any
  description = "Metadata of the cluster to attach the node pool to."
}
