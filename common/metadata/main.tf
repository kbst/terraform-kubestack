locals {
  name_prefix     = var.name_prefix                                           # e.g. kbst
  workspace       = var.workspace != "" ? var.workspace : terraform.workspace # ops or apps defaults to the selected terraform workspace
  provider_name   = var.provider_name                                         # e.g. gcp
  provider_region = var.provider_region                                       # e.g. europe-west3
  base_domain     = var.base_domain                                           # e.g. infra.example.com

  name_delimiter = var.delimiter # use dash as delimiter by default
  dns_delimiter  = "."           # dns uses a dot as delimiter

  # [name_prefix]-[workspace]-[provider_region]
  # e.g. kbst-ops-europe-west3
  name_parts = [local.name_prefix, local.workspace, local.provider_region]

  name = join(local.name_delimiter, compact(local.name_parts))

  # [provider_name].[base_domain]
  # e.g. gcp.infra.example.com
  split_base_domain = split(local.dns_delimiter, local.base_domain)

  domain_parts = concat([local.provider_name], compact(local.split_base_domain))

  domain = join(local.dns_delimiter, local.domain_parts)

  # [name_prefix]-[workspace]-[provider_region].[provider_name].[base_domain]
  # e.g. kbst-ops-europe-west3.gcp.infra.example.com
  fqdn_parts = [local.name, local.domain]

  fqdn = join(local.dns_delimiter, local.fqdn_parts)

  labels = {
    "${var.label_namespace}cluster_name"            = local.name
    "${var.label_namespace}cluster_domain"          = local.domain
    "${var.label_namespace}cluster_fqdn"            = local.fqdn
    "${var.label_namespace}cluster_workspace"       = local.workspace
    "${var.label_namespace}cluster_provider_name"   = local.provider_name
    "${var.label_namespace}cluster_provider_region" = local.provider_region
  }

  tags = [
    local.name,
    local.workspace,
    local.provider_name,
    local.provider_region,
  ]
}

