variable "configuration" {
  type = map(object({
    # Required attributes
    name_prefix = optional(string)
    base_domain = optional(string)

    # Optional attributes with defaults
    cluster_availability_zones = optional(list(string))

    cluster_vpc_cidr                      = optional(string)
    cluster_vpc_subnet_newbits            = optional(number)
    cluster_vpc_control_subnet_newbits    = optional(number)
    cluster_vpc_dns_hostnames             = optional(bool)
    cluster_vpc_dns_support               = optional(bool)
    cluster_vpc_node_subnet_newbits       = optional(number)
    cluster_vpc_node_subnet_number_offset = optional(number)
    cluster_vpc_legacy_node_subnets       = optional(bool)
    cluster_vpc_subnet_map_public_ip      = optional(bool)

    default_node_pool = optional(object({
      desired_capacity = optional(number)
      max_size         = optional(number)
      min_size         = optional(number)
      instance_types   = optional(list(string))
      metadata_options = optional(object({
        http_endpoint               = optional(string)
        http_tokens                 = optional(string)
        http_put_response_hop_limit = optional(number)
        http_protocol_ipv6          = optional(string)
        instance_metadata_tags      = optional(string)
      }))
      additional_node_tags    = optional(map(string))
      labels                  = optional(map(string))
      root_device_volume_size = optional(number)
      root_device_encrypted   = optional(bool)
      ami_type                = optional(string)
      ami_release_version     = optional(string)
    }))

    cluster_version = optional(string)

    cluster_aws_auth_map_roles    = optional(string)
    cluster_aws_auth_map_users    = optional(string)
    cluster_aws_auth_map_accounts = optional(string)

    disable_default_ingress = optional(bool)

    enabled_cluster_log_types = optional(list(string))

    disable_openid_connect_provider = optional(bool)

    cluster_endpoint_private_access = optional(bool)
    cluster_endpoint_public_access  = optional(bool)
    cluster_public_access_cidrs     = optional(list(string))
    cluster_service_cidr            = optional(string)

    cluster_encryption_key_arn = optional(string)
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
