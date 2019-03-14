module "cluster_metadata" {
  source = "../../common/metadata"

  name_prefix = "${local.name_prefix}"
  base_domain = "${local.base_domain}"

  provider_name   = "digitalocean"
  provider_region =  "${local.region}"
}

module "cluster" {
  source = "../_modules/do_ks"

  metadata_name   = "${module.cluster_metadata.name}"
  metadata_fqdn   = "${module.cluster_metadata.fqdn}"
  metadata_labels = "${module.cluster_metadata.labels}"
  metadata_tags = "${module.cluster_metadata.tags}"
  node_type = "${local.cluster_machine_type}"
  initial_node_count = "${local.cluster_initial_node_count}"
  region = "${local.region}"
}
