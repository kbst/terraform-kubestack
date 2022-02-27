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

  cluster_availability_zones_lookup = lookup(local.cfg, "cluster_availability_zones", "")
  cluster_availability_zones        = split(",", local.cluster_availability_zones_lookup)

  cluster_vpc_cidr                      = lookup(local.cfg, "cluster_vpc_cidr", "10.0.0.0/16")
  cluster_vpc_subnet_newbits            = lookup(local.cfg, "cluster_vpc_subnet_newbits", "8") # kept for backward compatibility
  cluster_vpc_control_subnet_newbits    = lookup(local.cfg, "cluster_vpc_control_subnet_newbits", local.cluster_vpc_subnet_newbits)
  cluster_vpc_dns_hostnames             = lookup(local.cfg, "cluster_vpc_dns_hostnames", false)
  cluster_vpc_dns_support               = lookup(local.cfg, "cluster_vpc_dns_support", true)
  cluster_vpc_node_subnet_newbits       = lookup(local.cfg, "cluster_vpc_node_subnet_newbits", "4")
  cluster_vpc_node_subnet_number_offset = lookup(local.cfg, "cluster_vpc_node_subnet_number_offset", "1")
  cluster_vpc_legacy_node_subnets       = lookup(local.cfg, "cluster_vpc_legacy_node_subnets", false)
  cluster_vpc_subnet_map_public_ip      = lookup(local.cfg, "cluster_vpc_subnet_map_public_ip", true)

  cluster_instance_type_lookup  = lookup(local.cfg, "cluster_instance_type", "")
  cluster_instance_types_lookup = lookup(local.cfg, "cluster_instance_types", local.cluster_instance_type_lookup)
  cluster_instance_types        = toset(split(",", local.cluster_instance_types_lookup))

  cluster_additional_node_tags_lookup = lookup(local.cfg, "cluster_additional_node_tags", "")
  cluster_additional_node_tags_tuples = [for t in split(",", local.cluster_additional_node_tags_lookup) : split("=", t)]
  cluster_additional_node_tags        = { for t in local.cluster_additional_node_tags_tuples : t[0] => t[1] if length(t) == 2 }

  cluster_desired_capacity = local.cfg["cluster_desired_capacity"]

  cluster_max_size = local.cfg["cluster_max_size"]

  cluster_min_size = local.cfg["cluster_min_size"]

  cluster_version = lookup(local.cfg, "cluster_version", null)

  worker_root_device_volume_size = lookup(local.cfg, "worker_root_device_volume_size", null)
  worker_root_device_encrypted   = lookup(local.cfg, "worker_root_device_encrypted", null)

  cluster_aws_auth_map_roles    = lookup(local.cfg, "cluster_aws_auth_map_roles", "")
  cluster_aws_auth_map_users    = lookup(local.cfg, "cluster_aws_auth_map_users", "")
  cluster_aws_auth_map_accounts = lookup(local.cfg, "cluster_aws_auth_map_accounts", "")

  disable_default_ingress = lookup(local.cfg, "disable_default_ingress", false)

  enabled_cluster_log_types_lookup = lookup(local.cfg, "enabled_cluster_log_types", "api,audit,authenticator,controllerManager,scheduler")
  enabled_cluster_log_types        = compact(split(",", local.enabled_cluster_log_types_lookup))

  disable_openid_connect_provider = lookup(local.cfg, "disable_openid_connect_provider", false)

  cluster_endpoint_private_access    = lookup(local.cfg, "cluster_endpoint_private_access", false)
  cluster_endpoint_public_access     = lookup(local.cfg, "cluster_endpoint_public_access", true)
  cluster_public_access_cidrs_lookup = lookup(local.cfg, "cluster_public_access_cidrs", null)
  cluster_public_access_cidrs        = local.cluster_public_access_cidrs_lookup == null ? null : split(",", local.cluster_public_access_cidrs_lookup)
}
