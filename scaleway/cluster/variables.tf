variable "configuration" {
  type = map(object({
    # Required attributes
    name_prefix = optional(string)
    base_domain = optional(string)
    region      = optional(string)

    # Kubernetes cluster required
    cluster_version = optional(string)
    cni             = optional(string)

    # Optional attributes without defaults
    delete_additional_resources = optional(bool)
    description                 = optional(string)

    project_id = optional(string)

    pod_cidr     = optional(string)
    service_cidr = optional(string)

    feature_gates     = optional(list(string))
    admission_plugins = optional(list(string))

    autoscaler_config = optional(object({
      disable_scale_down               = optional(bool)
      scale_down_delay_after_add       = optional(string)
      scale_down_unneeded_time         = optional(string)
      estimator                        = optional(string)
      expander                         = optional(string)
      ignore_daemonsets_utilization    = optional(bool)
      balance_similar_node_groups      = optional(bool)
      expendable_pods_priority_cutoff  = optional(number)
      scale_down_utilization_threshold = optional(number)
      max_graceful_termination_sec     = optional(number)
    }))

    auto_upgrade = optional(object({
      enable                        = optional(bool)
      maintenance_window_start_hour = optional(number)
      maintenance_window_day        = optional(string)
    }))

    # VPC
    vpc_enable_routing = optional(bool)

    # Private network
    private_network_subnet = optional(string)

    # Extra tags added to all cloud resources in addition to the metadata tags
    extra_tags = optional(list(string))

    disable_default_ingress = optional(bool)

    default_node_pool = optional(object({
      node_type              = optional(string)
      size                   = optional(number)
      min_size               = optional(number)
      max_size               = optional(number)
      autoscaling            = optional(bool)
      autohealing            = optional(bool)
      container_runtime      = optional(string)
      root_volume_type       = optional(string)
      root_volume_size_in_gb = optional(number)
      public_ip_disabled     = optional(bool)

      # Availability zones to deploy the default node pool into.
      # One scaleway_k8s_pool is created per zone.
      # e.g. ["fr-par-1", "fr-par-2", "fr-par-3"]
      zones = optional(list(string))

      kubelet_args = optional(map(string))

      upgrade_policy = optional(object({
        max_surge       = optional(number)
        max_unavailable = optional(number)
      }))

      node_taints = optional(list(object({
        key    = string
        value  = string
        effect = string
      })))

      # Extra tags added to node pool cloud resources in addition to the metadata tags
      tags = optional(list(string))
    }))
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
