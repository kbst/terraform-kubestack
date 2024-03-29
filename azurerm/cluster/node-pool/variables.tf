variable "configuration" {
  type = map(object({
    node_pool_name = optional(string)
    vm_size        = optional(string)
    node_count     = optional(string)

    enable_auto_scaling = optional(bool)
    max_count           = optional(string)
    min_count           = optional(string)
    eviction_policy     = optional(string)

    max_pods        = optional(string)
    os_disk_type    = optional(string)
    os_disk_size_gb = optional(string)

    use_spot       = optional(bool)
    max_spot_price = optional(string)

    node_labels        = optional(map(string))
    node_taints        = optional(list(string))
    availability_zones = optional(list(string))
  }))
  description = "Map with per workspace node pool configuration."
}

variable "configuration_base_key" {
  type        = string
  description = "The key in the configuration map all other keys inherit from."
  default     = "apps"
}

variable "cluster_name" {
  type        = string
  description = "The name of the cluster to attach the node pool to"
}

variable "resource_group" {
  type        = string
  description = "The resource group of the cluster to attach the node pool to"
}
