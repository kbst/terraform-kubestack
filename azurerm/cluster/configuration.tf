module "configuration" {
  source = "../../common/configuration"

  configuration = var.configuration
  base_key      = var.configuration_base_key
}

locals {
  # current workspace config
  cfg = module.configuration.merged[terraform.workspace]

  name_prefix = local.cfg["name_prefix"]

  base_domain = local.cfg["base_domain"]

  resource_group = local.cfg["resource_group"]

  dns_prefix = lookup(local.cfg, "dns_prefix", "api")

  sku_tier = lookup(local.cfg, "sku_tier", "Free")

  legacy_vnet_name        = lookup(local.cfg, "legacy_vnet_name", false)
  vnet_address_space      = split(",", lookup(local.cfg, "vnet_address_space", "10.0.0.0/8"))
  subnet_address_prefixes = split(",", lookup(local.cfg, "subnet_address_prefixes", "10.1.0.0/16"))

  subnet_service_endpoints_lookup = lookup(local.cfg, "subnet_service_endpoints", "")
  subnet_service_endpoints        = local.subnet_service_endpoints_lookup != "" ? split(",", local.subnet_service_endpoints_lookup) : []

  network_plugin = lookup(local.cfg, "network_plugin", "kubenet")
  network_policy = lookup(local.cfg, "network_policy", "calico")
  service_cidr   = lookup(local.cfg, "service_cidr", "10.0.0.0/16")
  dns_service_ip = lookup(local.cfg, "dns_service_ip", "10.0.0.10")
  pod_cidr       = lookup(local.cfg, "pod_cidr", "10.244.0.0/16")
  max_pods       = lookup(local.cfg, "max_pods", null)

  default_node_pool_name = lookup(local.cfg, "default_node_pool_name", "default")
  default_node_pool_type = lookup(local.cfg, "default_node_pool_type", "VirtualMachineScaleSets")

  default_node_pool_enable_auto_scaling = lookup(local.cfg, "default_node_pool_enable_auto_scaling", true)
  default_node_pool_min_count           = lookup(local.cfg, "default_node_pool_min_count", "1")
  default_node_pool_max_count           = lookup(local.cfg, "default_node_pool_max_count", "1")
  default_node_pool_node_count          = lookup(local.cfg, "default_node_pool_node_count", "1")

  default_node_pool_vm_size              = lookup(local.cfg, "default_node_pool_vm_size", "Standard_B2s")
  default_node_pool_only_critical_addons = lookup(local.cfg, "default_node_pool_only_critical_addons", false)
  default_node_pool_os_disk_size_gb      = lookup(local.cfg, "default_node_pool_os_disk_size_gb", "30")

  disable_default_ingress = lookup(local.cfg, "disable_default_ingress", false)

  default_ingress_ip_zones_lookup = lookup(local.cfg, "default_ingress_ip_zones", "")
  default_ingress_ip_zones        = local.default_ingress_ip_zones_lookup != "" ? split(",", local.default_ingress_ip_zones_lookup) : []

  enable_azure_policy_agent = lookup(local.cfg, "enable_azure_policy_agent", false)

  disable_managed_identities = lookup(local.cfg, "disable_managed_identities", false)
  user_assigned_identity_id  = lookup(local.cfg, "user_assigned_identity_id", null)

  enable_log_analytics = lookup(local.cfg, "enable_log_analytics", true)

  kubernetes_version        = lookup(local.cfg, "kubernetes_version", null)
  automatic_channel_upgrade = lookup(local.cfg, "automatic_channel_upgrade", null)

  availability_zones_lookup = lookup(local.cfg, "availability_zones", "")
  availability_zones        = local.availability_zones_lookup != "" ? split(",", local.availability_zones_lookup) : []

  additional_metadata_labels_lookup = lookup(local.cfg, "additional_metadata_labels", "")
  additional_metadata_labels_tuples = [for t in split(",", local.additional_metadata_labels_lookup) : split("=", t)]
  additional_metadata_labels        = { for t in local.additional_metadata_labels_tuples : t[0] => t[1] if length(t) == 2 }
}
