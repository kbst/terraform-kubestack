locals {
  # apps config and merged ops config
  workspaces = {
    apps = var.configuration["apps"]
    ops  = merge(var.configuration["apps"], var.configuration["ops"])
  }

  # current workspace config
  cfg = local.workspaces[terraform.workspace]

  name_prefix = local.cfg["name_prefix"]

  base_domain = local.cfg["base_domain"]

  resource_group = local.cfg["resource_group"]

  dns_prefix = lookup(local.cfg, "dns_prefix", "api")

  agent_pool_profile_name = lookup(local.cfg, "agent_pool_profile_name", "default")

  agent_pool_profile_count = lookup(local.cfg, "agent_pool_profile_count", "1")

  agent_pool_profile_vm_size = lookup(local.cfg, "agent_pool_profile_vm_size", "Standard_D1_v2")

  agent_pool_profile_os_type = lookup(local.cfg, "agent_pool_profile_os_type", "Linux")

  agent_pool_profile_os_disk_size_gb = lookup(local.cfg, "agent_pool_profile_os_disk_size_gb", "30")
}

