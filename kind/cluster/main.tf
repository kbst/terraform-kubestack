module "cluster_metadata" {
  source = "../../common/metadata"

  name_prefix = "${local.name_prefix}"
  base_domain = "${local.base_domain}"

  provider_name   = "kind"
  provider_region = "localhost"
}

module "cluster" {
  source = "../_modules/kind"

  metadata_name   = "${module.cluster_metadata.name}"
  metadata_fqdn   = "${module.cluster_metadata.fqdn}"
  metadata_tags   = "${module.cluster_metadata.tags}"
  metadata_labels = "${module.cluster_metadata.labels}"

  node_roles = "${local.node_roles}"
}
