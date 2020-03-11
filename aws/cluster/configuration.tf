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

  cluster_availability_zones_lookup = lookup(local.cfg, "cluster_availability_zones", "")
  cluster_availability_zones        = split(",", local.cluster_availability_zones_lookup)

  cluster_instance_type = local.cfg["cluster_instance_type"]

  cluster_desired_capacity = local.cfg["cluster_desired_capacity"]

  cluster_max_size = local.cfg["cluster_max_size"]

  cluster_min_size = local.cfg["cluster_min_size"]

  worker_root_device_volume_size = lookup(local.cfg, "worker_root_device_volume_size", null)
  worker_root_device_encrypted   = lookup(local.cfg, "worker_root_device_encrypted", null)

  cluster_aws_auth_map_roles    = lookup(local.cfg, "cluster_aws_auth_map_roles", "")
  cluster_aws_auth_map_users    = lookup(local.cfg, "cluster_aws_auth_map_users", "")
  cluster_aws_auth_map_accounts = lookup(local.cfg, "cluster_aws_auth_map_accounts", "")

  kbp_default          = "manifests/overlays/${terraform.workspace}"
  kustomize_build_path = lookup(local.cfg, "kustomize_build_path", local.kbp_default)
}
