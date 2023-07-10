data "azurerm_resource_group" "current" {
  name = local.resource_group
}

module "cluster_metadata" {
  source = "../../common/metadata"

  name_prefix = local.name_prefix
  base_domain = local.base_domain

  provider_name   = "azure"
  provider_region = data.azurerm_resource_group.current.location

  # Azure does not allow / character in labels
  label_namespace = "kubestack.com-"
}

module "cluster" {
  source = "../_modules/aks"

  resource_group = local.resource_group

  metadata_name            = module.cluster_metadata.name
  metadata_fqdn            = module.cluster_metadata.fqdn
  metadata_labels          = merge(module.cluster_metadata.labels, local.additional_metadata_labels)
  metadata_label_namespace = module.cluster_metadata.label_namespace

  dns_prefix = local.dns_prefix

  sku_tier = local.sku_tier

  legacy_vnet_name         = local.legacy_vnet_name
  vnet_address_space       = local.vnet_address_space
  subnet_address_prefixes  = local.subnet_address_prefixes
  subnet_service_endpoints = local.subnet_service_endpoints

  network_plugin = local.network_plugin
  network_policy = local.network_policy
  service_cidr   = local.service_cidr
  dns_service_ip = local.dns_service_ip
  pod_cidr       = local.pod_cidr
  max_pods       = local.max_pods

  default_node_pool_name = local.default_node_pool_name
  default_node_pool_type = local.default_node_pool_type

  default_node_pool_enable_auto_scaling = local.default_node_pool_enable_auto_scaling
  default_node_pool_min_count           = local.default_node_pool_min_count
  default_node_pool_max_count           = local.default_node_pool_max_count
  default_node_pool_node_count          = local.default_node_pool_node_count

  default_node_pool_only_critical_addons = local.default_node_pool_only_critical_addons
  default_node_pool_vm_size              = local.default_node_pool_vm_size
  default_node_pool_os_disk_size_gb      = local.default_node_pool_os_disk_size_gb

  disable_default_ingress  = local.disable_default_ingress
  default_ingress_ip_zones = local.default_ingress_ip_zones

  enable_azure_policy_agent = local.enable_azure_policy_agent

  disable_managed_identities = local.disable_managed_identities
  user_assigned_identity_id  = local.user_assigned_identity_id

  kubernetes_version        = local.kubernetes_version
  automatic_channel_upgrade = local.automatic_channel_upgrade
  enable_log_analytics      = local.enable_log_analytics

  availability_zones = local.availability_zones
}
