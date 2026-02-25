variable "configuration" {
  type = map(object({
    name = optional(string)

    node_type = optional(string)
    size      = optional(number)
    min_size  = optional(number)
    max_size  = optional(number)

    autoscaling = optional(bool)
    autohealing = optional(bool)

    container_runtime      = optional(string)
    root_volume_type       = optional(string)
    root_volume_size_in_gb = optional(number)

    public_ip_disabled = optional(bool)

    zones = optional(list(string))

    wait_for_pool_ready = optional(bool)

    kubelet_args = optional(map(string))

    upgrade_policy = optional(object({
      max_surge       = optional(number)
      max_unavailable = optional(number)
    }))

    # node_taints follow the Scaleway tag convention:
    # they are converted to "taint=key=value:Effect" tag strings automatically.
    node_taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })))

    tags = optional(list(string))
  }))

  description = "Map with per workspace node pool configuration."
  nullable    = false
}

variable "configuration_base_key" {
  type        = string
  description = "The key in the configuration map all other keys inherit from."
  default     = "apps"
  nullable    = false
}

variable "cluster" {
  type        = any
  description = "The cluster output from the cluster module."
  nullable    = false
}

variable "cluster_metadata" {
  type        = any
  description = "Metadata of the cluster to attach the node pool to."
  nullable    = false
}
