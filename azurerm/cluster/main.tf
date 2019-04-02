data "azurerm_resource_group" "current" {
  name = "${local.resource_group}"
}

module "cluster_metadata" {
  source = "../../common/metadata"

  name_prefix = "${local.name_prefix}"
  base_domain = "${local.base_domain}"

  provider_name   = "azure"
  provider_region = "${data.azurerm_resource_group.current.location}"

  # Azure does not allow / character in labels
  label_namespace = "kubestack.com-"
}

module "cluster" {
  source = "../_modules/aks"

  resource_group = "${local.resource_group}"

  metadata_name            = "${module.cluster_metadata.name}"
  metadata_fqdn            = "${module.cluster_metadata.fqdn}"
  metadata_labels          = "${module.cluster_metadata.labels}"
  metadata_label_namespace = "${module.cluster_metadata.label_namespace}"

  agent_pool_profile_name             = "${local.worker_nodes_name}"
  agent_pool_profile_count            = "${local.worker_nodes_count}"
  agent_pool_profile_vm_size          = "${local.worker_nodes_vm_size}"
  agent_pool_profile_os_type          = "${local.worker_nodes_os_type}"
  agent_pool_profile_os_disk_size_gb  = "${local.worker_nodes_os_disk_size_gb}"

}
