variable "configuration" {
  type = map(object({
    node_pool_name = optional(string)
    vm_size        = optional(string)
    node_count     = optional(number)

    enable_auto_scaling = optional(bool)
    max_count           = optional(number)
    min_count           = optional(number)
    eviction_policy     = optional(string)

    max_pods        = optional(number)
    os_disk_type    = optional(string)
    os_disk_size_gb = optional(number)

    use_spot       = optional(bool)
    max_spot_price = optional(number)

    node_labels        = optional(map(string))
    node_taints        = optional(list(string))
    availability_zones = optional(list(string))

    upgrade_settings = optional(object({
      max_surge                     = optional(string)
      drain_timeout_in_minutes      = optional(number)
      node_soak_duration_in_minutes = optional(number)
    }))
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
