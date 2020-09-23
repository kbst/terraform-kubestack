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

  network_plugin = lookup(local.cfg, "network_plugin", "kubenet")
  service_cidr   = lookup(local.cfg, "service_cidr", "10.0.0.0/16")
  dns_service_ip = lookup(local.cfg, "dns_service_ip", "10.0.0.10")
  max_pods       = lookup(local.cfg, "max_pods", null)

  default_node_pool_name = lookup(local.cfg, "default_node_pool_name", "default")
  default_node_pool_type = lookup(local.cfg, "default_node_pool_type", "VirtualMachineScaleSets")

  default_node_pool_enable_auto_scaling = lookup(local.cfg, "default_node_pool_enable_auto_scaling", true)
  default_node_pool_min_count           = lookup(local.cfg, "default_node_pool_min_count", "1")
  default_node_pool_max_count           = lookup(local.cfg, "default_node_pool_max_count", "1")
  default_node_pool_node_count          = lookup(local.cfg, "default_node_pool_node_count", "1")

  default_node_pool_vm_size = lookup(local.cfg, "default_node_pool_vm_size", "Standard_B2s")

  default_node_pool_os_disk_size_gb = lookup(local.cfg, "default_node_pool_os_disk_size_gb", "30")

  manifest_path_default = "manifests/overlays/${terraform.workspace}"
  manifest_path         = var.manifest_path != null ? var.manifest_path : local.manifest_path_default

  disable_default_ingress = lookup(local.cfg, "disable_default_ingress", false)

  service_principal_end_date_relative = lookup(local.cfg, "service_principal_end_date_relative", "8766h")
}
