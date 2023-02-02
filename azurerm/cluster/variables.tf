variable "configuration" {
  type = map(object({
    name_prefix = optional(string)
    base_domain = optional(string)

    resource_group = optional(string)

    dns_prefix = optional(string)

    sku_tier = optional(string)

    legacy_vnet_name        = optional(bool)
    vnet_address_space      = optional(list(string))
    subnet_address_prefixes = optional(list(string))

    subnet_service_endpoints = optional(list(string))

    network_plugin = optional(string)
    network_policy = optional(string)

    dns_service_ip = optional(string)

    service_cidr = optional(string)
    pod_cidr     = optional(string)

    max_pods = optional(string)

    default_node_pool_name = optional(string)
    default_node_pool_type = optional(string)

    default_node_pool_enable_auto_scaling = optional(bool)
    default_node_pool_min_count           = optional(number)
    default_node_pool_max_count           = optional(number)
    default_node_pool_node_count          = optional(number)

    default_node_pool_vm_size              = optional(string)
    default_node_pool_only_critical_addons = optional(bool)
    default_node_pool_os_disk_size_gb      = optional(number)

    disable_default_ingress  = optional(bool)
    default_ingress_ip_zones = optional(list(string))

    enable_azure_policy_agent = optional(bool)

    disable_managed_identities = optional(bool)
    user_assigned_identity_id  = optional(string)

    enable_log_analytics = optional(bool)

    kubernetes_version        = optional(string)
    automatic_channel_upgrade = optional(string)

    availability_zones = optional(list(string))

    additional_metadata_labels = optional(map(string))
  }))
  description = "Map with per workspace cluster configuration."
}

variable "configuration_base_key" {
  type        = string
  description = "The key in the configuration map all other keys inherit from."
  default     = "apps"
}
