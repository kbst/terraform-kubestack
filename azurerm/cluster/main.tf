data "azurerm_resource_group" "current" {
  name = local.cfg["resource_group"]
}

module "cluster_metadata" {
  source = "../../common/metadata"

  name_prefix = local.cfg["name_prefix"]
  base_domain = local.cfg["base_domain"]

  provider_name   = "azure"
  provider_region = data.azurerm_resource_group.current.location

  # Azure does not allow / character in labels
  label_namespace = "kubestack.com-"
}

module "cluster" {
  source = "../_modules/aks"

  resource_group = local.cfg["resource_group"]

  metadata_name            = module.cluster_metadata.name
  metadata_fqdn            = module.cluster_metadata.fqdn
  metadata_labels          = merge(module.cluster_metadata.labels, local.cfg["additional_metadata_labels"])
  metadata_label_namespace = module.cluster_metadata.label_namespace

  dns_prefix = local.cfg["dns_prefix"] != null ? local.cfg["dns_prefix"] : "api"

  sku_tier = local.cfg["sku_tier"] != null ? local.cfg["sku_tier"] : "Free"

  legacy_vnet_name         = local.cfg["legacy_vnet_name"] != null ? local.cfg["legacy_vnet_name"] : false
  vnet_address_space       = local.cfg["vnet_address_space"] != null ? local.cfg["vnet_address_space"] : ["10.0.0.0/8"]
  subnet_address_prefixes  = local.cfg["subnet_address_prefixes"] != null ? local.cfg["subnet_address_prefixes"] : ["10.1.0.0/16"]
  subnet_service_endpoints = local.cfg["subnet_service_endpoints"]

  network_plugin = local.cfg["network_plugin"] != null ? local.cfg["network_plugin"] : "kubenet"
  network_policy = local.cfg["network_policy"] != null ? local.cfg["network_policy"] : "calico"

  dns_service_ip = local.cfg["dns_service_ip"] != null ? local.cfg["dns_service_ip"] : "10.0.0.10"

  service_cidr = local.cfg["service_cidr"] != null ? local.cfg["service_cidr"] : "10.0.0.0/16"
  pod_cidr     = local.cfg["pod_cidr"] != null ? local.cfg["pod_cidr"] : "10.244.0.0/16"

  max_pods = local.cfg["max_pods"]

  default_node_pool_name = local.cfg["default_node_pool_name"] != null ? local.cfg["default_node_pool_name"] : "default"
  default_node_pool_type = local.cfg["default_node_pool_type"] != null ? local.cfg["default_node_pool_type"] : "VirtualMachineScaleSets"

  default_node_pool_enable_auto_scaling = local.cfg["default_node_pool_enable_auto_scaling"] != null ? local.cfg["default_node_pool_enable_auto_scaling"] : true
  default_node_pool_min_count           = local.cfg["default_node_pool_min_count"] != null ? local.cfg["default_node_pool_min_count"] : 1
  default_node_pool_max_count           = local.cfg["default_node_pool_max_count"] != null ? local.cfg["default_node_pool_max_count"] : 1
  default_node_pool_node_count          = local.cfg["default_node_pool_node_count"] != null ? local.cfg["default_node_pool_node_count"] : 1

  default_node_pool_vm_size              = local.cfg["default_node_pool_vm_size"] != null ? local.cfg["default_node_pool_vm_size"] : "Standard_B2s"
  default_node_pool_only_critical_addons = local.cfg["default_node_pool_only_critical_addons"] != null ? local.cfg["default_node_pool_only_critical_addons"] : false
  default_node_pool_os_disk_size_gb      = local.cfg["default_node_pool_os_disk_size_gb"] != null ? local.cfg["default_node_pool_os_disk_size_gb"] : 30

  disable_default_ingress  = local.cfg["disable_default_ingress"] != null ? local.cfg["disable_default_ingress"] : false
  default_ingress_ip_zones = local.cfg["default_ingress_ip_zones"]

  enable_azure_policy_agent = local.cfg["enable_azure_policy_agent"] != null ? local.cfg["enable_azure_policy_agent"] : false

  disable_managed_identities = local.cfg["disable_managed_identities"] != null ? local.cfg["disable_managed_identities"] : false
  user_assigned_identity_id  = local.cfg["user_assigned_identity_id"]

  enable_log_analytics = local.cfg["enable_log_analytics"] != null ? local.cfg["enable_log_analytics"] : true

  kubernetes_version        = local.cfg["kubernetes_version"]
  automatic_channel_upgrade = local.cfg["automatic_channel_upgrade"]

  availability_zones = local.cfg["availability_zones"]
}
