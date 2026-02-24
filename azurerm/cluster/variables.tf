variable "configuration" {
  type = map(object({
    # Required attributes
    name_prefix    = optional(string)
    base_domain    = optional(string)
    resource_group = optional(string)

    # Optional attributes without defaults
    dns_prefix = optional(string)
    sku_tier   = optional(string)

    legacy_vnet_name         = optional(bool)
    vnet_address_space       = optional(list(string))
    subnet_address_prefixes  = optional(list(string))
    subnet_service_endpoints = optional(list(string))

    network_plugin = optional(string)
    network_policy = optional(string)
    service_cidr   = optional(string)
    dns_service_ip = optional(string)
    pod_cidr       = optional(string)
    max_pods       = optional(number)

    default_node_pool = optional(object({
      name                 = optional(string)
      type                 = optional(string)
      enable_auto_scaling  = optional(bool)
      min_count            = optional(number)
      max_count            = optional(number)
      node_count           = optional(number)
      vm_size              = optional(string)
      only_critical_addons = optional(bool)
      os_disk_size_gb      = optional(number)
      upgrade_settings = optional(object({
        max_surge                     = optional(string)
        drain_timeout_in_minutes      = optional(number)
        node_soak_duration_in_minutes = optional(number)
      }))
    }))

    disable_default_ingress = optional(bool)

    default_ingress_ip_zones = optional(list(string))

    enable_azure_policy_agent = optional(bool)

    disable_managed_identities = optional(bool)
    user_assigned_identity_id  = optional(string)

    enable_log_analytics = optional(bool)

    kubernetes_version        = optional(string)
    automatic_channel_upgrade = optional(string)

    availability_zones = optional(list(string))

    additional_metadata_labels = optional(map(string))

    keda_enabled                    = optional(bool)
    vertical_pod_autoscaler_enabled = optional(bool)
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
