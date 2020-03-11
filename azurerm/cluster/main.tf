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
  metadata_labels          = module.cluster_metadata.labels
  metadata_label_namespace = module.cluster_metadata.label_namespace

  dns_prefix = local.dns_prefix

  default_node_pool_name = local.default_node_pool_name
  default_node_pool_type = local.default_node_pool_type

  default_node_pool_enable_auto_scaling = local.default_node_pool_enable_auto_scaling
  default_node_pool_min_count           = local.default_node_pool_min_count
  default_node_pool_max_count           = local.default_node_pool_max_count
  default_node_pool_node_count          = local.default_node_pool_node_count

  default_node_pool_vm_size         = local.default_node_pool_vm_size
  default_node_pool_os_disk_size_gb = local.default_node_pool_os_disk_size_gb

  kustomize_build_path = local.kustomize_build_path
}
