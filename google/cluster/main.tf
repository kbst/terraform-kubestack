module "cluster_metadata" {
  source = "../../common/metadata"

  name_prefix = "${local.name_prefix}"
  base_domain = "${local.base_domain}"

  provider_name   = "gcp"
  provider_region = "${local.region}"
}

module "cluster" {
  source = "../_modules/gke"

  project        = "${local.project_id}"
  location       = "${local.region}"
  node_locations = "${local.cluster_node_locations}"

  metadata_name   = "${module.cluster_metadata.name}"
  metadata_fqdn   = "${module.cluster_metadata.fqdn}"
  metadata_tags   = "${module.cluster_metadata.tags}"
  metadata_labels = "${module.cluster_metadata.labels}"

  min_master_version = "${local.cluster_min_master_version}"
  initial_node_count = "${local.cluster_initial_node_count}"
  additional_zones   = "${local.cluster_additional_zones}"

  daily_maintenance_window_start_time = "${local.cluster_daily_maintenance_window_start_time}"
}

module "node_pool" {
  source = "../_modules/gke/node_pool"

  project  = "${local.project_id}"
  location = "${local.region}"

  pool_name             = "default"
  service_account_email = "${module.cluster.service_account_email}"

  metadata_name   = "${module.cluster_metadata.name}"
  metadata_fqdn   = "${module.cluster_metadata.fqdn}"
  metadata_tags   = "${module.cluster_metadata.tags}"
  metadata_labels = "${module.cluster_metadata.labels}"

  initial_node_count = 1
  min_node_count     = "${local.cluster_min_node_count}"
  max_node_count     = "${local.cluster_max_node_count}"

  extra_oauth_scopes = "${local.cluster_extra_oauth_scopes}"
  disk_size_gb       = "${local.cluster_disk_size_gb}"
  disk_type          = "${local.cluster_disk_type}"
  machine_type       = "${local.cluster_machine_type}"
}
