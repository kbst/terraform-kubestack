variable "configuration" {
  type = map(object({

    name = optional(string)

    instance_types   = optional(string)
    desired_capacity = optional(string)
    min_size         = optional(string)
    max_size         = optional(string)
    disk_size        = optional(string)

    ami_type = optional(string)

    availability_zones = optional(string)

    vpc_subnet_ids = optional(string)

    vpc_secondary_cidr = optional(string)

    vpc_subnet_newbits       = optional(string)
    vpc_subnet_number_offset = optional(string)
    vpc_subnet_map_public_ip = optional(bool)

    taints = optional(set(object({
      key    = string
      value  = string
      effect = string
    })))

    launch_template_id      = optional(string)
    launch_template_name    = optional(string)
    launch_template_version = optional(string)

    tags = optional(map(string))

    labels = optional(map(string))
  }))
  description = "Map with per workspace module configuration."
}

variable "configuration_base_key" {
  type        = string
  description = "The key in the configuration map all other keys inherit from."
  default     = "apps"
}

variable "cluster_name" {
  type        = string
  description = "Name of the cluster to attach the node pool to."
}
variable "cluster_default_node_pool_name" {
  type        = string
  description = "Name of the cluster's default node pool to inherit IAM role and subnets from."
  default     = "default"
}
