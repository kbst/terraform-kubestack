data "aws_region" "current" {
}

module "cluster_metadata" {
  source = "../../common/metadata"

  name_prefix = local.name_prefix
  base_domain = local.base_domain

  provider_name   = "aws"
  provider_region = data.aws_region.current.name
}

module "cluster" {
  source = "../_modules/eks"

  metadata_name   = module.cluster_metadata.name
  metadata_fqdn   = module.cluster_metadata.fqdn
  metadata_labels = module.cluster_metadata.labels

  availability_zones = local.cluster_availability_zones

  vpc_cidr                      = local.cluster_vpc_cidr
  vpc_control_subnet_newbits    = local.cluster_vpc_control_subnet_newbits
  vpc_dns_hostnames             = local.cluster_vpc_dns_hostnames
  vpc_dns_support               = local.cluster_vpc_dns_support
  vpc_node_subnet_newbits       = local.cluster_vpc_node_subnet_newbits
  vpc_node_subnet_number_offset = local.cluster_vpc_node_subnet_number_offset
  vpc_legacy_node_subnets       = local.cluster_vpc_legacy_node_subnets
  vpc_subnet_map_public_ip      = local.cluster_vpc_subnet_map_public_ip

  instance_types   = local.cluster_instance_types
  desired_capacity = local.cluster_desired_capacity
  max_size         = local.cluster_max_size
  min_size         = local.cluster_min_size
  cluster_version  = local.cluster_version

  metadata_options = local.metadata_options

  root_device_encrypted   = local.worker_root_device_encrypted
  root_device_volume_size = local.worker_root_device_volume_size

  additional_node_tags = local.cluster_additional_node_tags

  aws_auth_map_roles    = local.cluster_aws_auth_map_roles
  aws_auth_map_users    = local.cluster_aws_auth_map_users
  aws_auth_map_accounts = local.cluster_aws_auth_map_accounts

  disable_default_ingress = local.disable_default_ingress

  enabled_cluster_log_types = local.enabled_cluster_log_types

  disable_openid_connect_provider = local.disable_openid_connect_provider

  cluster_endpoint_private_access = local.cluster_endpoint_private_access
  cluster_endpoint_public_access  = local.cluster_endpoint_public_access
  cluster_public_access_cidrs     = local.cluster_public_access_cidrs
  cluster_service_cidr            = local.cluster_service_cidr

  cluster_encryption_key_arn = local.cluster_encryption_key_arn

  worker_ami_release_version = local.worker_ami_release_version

  # cluster module configuration is still map(string)
  # once module_variable_optional_attrs isn't experimental anymore
  # we can migrate cluster module configuration to map(object(...))
  taints = toset([])
}
