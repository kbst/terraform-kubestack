variable "cluster_name" {
  type        = string
  description = "Name of the cluster"
}

variable "resource_group" {
  type        = string
  description = "Resource group of the cluster."
}

variable "node_pool_name" {
  type        = string
  description = "Name of the node pool."
}

variable "enable_auto_scaling" {
  type        = bool
  description = "Whether to enable auto scaling for the node pool. Defaults to true"
}

variable "max_count" {
  # type        = optional(string)
  description = "Max number of nodes in the pool"
}

variable "min_count" {
  # type        = optional(string)
  description = "Min number of nodes in the pool"
}

variable "node_count" {
  type        = string
  description = "Static number of nodes in the pool"
}

variable "max_pods" {
  type        = string
  description = "Maximum number of pods per node"
}

variable "vm_size" {
  type        = string
  description = "VM size to use for the nodes in the pool"
}

variable "os_disk_type" {
  type        = string
  description = "The type of disk which should be used for the Operating System. Possible values are Ephemeral and Managed. Defaults to Managed. Changing this forces a new resource to be created."
}

variable "os_disk_size_gb" {
  # type        = optional(string)
  description = "The Agent Operating System disk size in GB. Changing this forces a new resource to be created."
}

variable "eviction_policy" {
  # type        = optional(string)
  description = "Eviction policy for when using spot instances. Possible values are 'Deallocate' and 'Delete'."
}

variable "priority" {
  type        = string
  description = "Whether to use spot instances. Possible values are 'Spot' and 'Regular'"
}

variable "max_spot_price" {
  # type        = optional(string)
  description = "The maximum desired spot price, or -1 for the current on-demand price"
}

variable "node_labels" {
  # type        = optional(map(string))
  description = "The labels that should be added to the nodes"
}

variable "node_taints" {
  # type        = optional(list(string))
  description = "The node taints that should be automatically applied"
}

variable "availability_zones" {
  # type        = optional(list(string))
  description = "The list of availability zones to create the node pool in"
}
