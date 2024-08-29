variable "project" {
  type        = string
  description = "Project the cluster belongs to."
}

variable "cluster_name" {
  type        = string
  description = "Name of the cluster for this node pool."
}

variable "metadata_tags" {
  type        = list(string)
  description = "Metadata tags to use."
}

variable "metadata_labels" {
  type        = map(string)
  description = "Metadata labels to use."
}

variable "pool_name" {
  description = "Name of the node pool."
  type        = string
}

variable "location" {
  type        = string
  description = "location of the cluster this node pool belongs to."
}

variable "initial_node_count" {
  description = "Initial number of nodes for this node pool."
  type        = string
}

variable "min_node_count" {
  description = "Min number of nodes for this node pool."
  type        = string
}

variable "max_node_count" {
  description = "Max number of nodes for this node pool."
  type        = string
}

variable "location_policy" {
  type        = string
  description = "Location policy specifies the algorithm used when scaling-up the node pool."
}

variable "service_account_email" {
  description = "The service account email to use for this node pool."
  type        = string
  default     = null
}

variable "disable_per_node_pool_service_account" {
  description = "Skip creating a dedicated service account to use for this node pool."
  type        = string
  default     = false
}

variable "extra_oauth_scopes" {
  description = "List of additional oauth scopes for workers."
  type        = list(string)
}

variable "disk_size_gb" {
  description = "The disk size of nodes in this pool."
  type        = string
}

variable "disk_type" {
  description = "The disk type of nodes in this pool."
  type        = string
}

variable "image_type" {
  description = "The image type for nodes in this pool."
  type        = string
  default     = "COS"
}

variable "machine_type" {
  description = "The machine type for nodes in this pool."
  type        = string
}

variable "preemptible" {
  description = "Whether to use preemptible nodes for this node pool."
  type        = string
  default     = false
}

variable "auto_repair" {
  description = "Whether the nodes will be automatically repaired."
  type        = string
  default     = true
}

variable "auto_upgrade" {
  description = "Whether the nodes will be automatically upgraded."
  type        = string
  default     = true
}

variable "node_workload_metadata_config" {
  description = "How to expose the node metadata to the workload running on the node."
  type        = string
}

variable "taints" {
  type = set(object({
    key    = string
    value  = string
    effect = string
  }))
  description = "Taints to configure for the node pool."
  default     = null
}

variable "instance_tags" {
  type = list(string)
  description = "List of instance tags to apply to nodes."
  default = []
}

variable "node_locations" {
  type        = list(string)
  description = "List of zones in the cluster's region to start worker nodes in. Defaults to cluster's node locations."
  default     = null
}

variable "guest_accelerator" {
  type = object({
    type               = string
    count              = number
    gpu_partition_size = optional(string)
    gpu_sharing_config = optional(object({
      gpu_sharing_strategy       = string
      max_shared_clients_per_gpu = number
    }))
  })
  description = "`guest_accelerator` block supports during node_group creation, useful to provision GPU-capable nodes. Default to `null` or `{}` which will disable GPUs."
  default     = null
}

variable "network_config" {
  type = object({
    enable_private_nodes = bool
    create_pod_range     = bool
    pod_ipv4_cidr_block  = string
  })
  description = "Additional network configuration for the node pool."
  default     = null
}
