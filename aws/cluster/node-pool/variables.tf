variable "configuration" {
  type = map(object({

    name = optional(string)

    instance_types      = optional(list(string))
    ami_release_version = optional(string)
    desired_capacity    = optional(number)
    min_size            = optional(number)
    max_size            = optional(number)
    disk_size           = optional(number)

    ami_type = optional(string)

    metadata_options = optional(object({
      http_endpoint               = optional(string)
      http_tokens                 = optional(string)
      http_put_response_hop_limit = optional(number)
      http_protocol_ipv6          = optional(string)
      instance_metadata_tags      = optional(string)
    }))

    availability_zones = optional(list(string))

    vpc_subnet_ids = optional(list(string))

    vpc_secondary_cidr = optional(string)

    vpc_subnet_newbits       = optional(number)
    vpc_subnet_number_offset = optional(number)
    vpc_subnet_map_public_ip = optional(bool)

    taints = optional(set(object({
      key    = string
      value  = string
      effect = string
    })))

    tags = optional(map(string))

    labels = optional(map(string))
  }))
  description = "Map with per workspace module configuration."
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

variable "cluster_default_node_pool_name" {
  type        = string
  description = "Name of the cluster's default node pool to inherit IAM role and subnets from."
  default     = "default"
  nullable    = false
}

variable "cluster_default_node_pool_subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for the default node pool subnet."
  default     = null
}
