module "cluster_metadata" {
  source = "../../common/metadata"

  name_prefix = "${var.name_prefix}"
  base_domain = "${var.base_domain}"

  provider_name   = "gcp"
  provider_region = "${var.region}"
}

module "cluster" {
  source = "../_modules/gke"

  project = "${var.project_id}"
  region  = "${var.region}"

  metadata_name   = "${module.cluster_metadata.name}"
  metadata_fqdn   = "${module.cluster_metadata.fqdn}"
  metadata_tags   = "${module.cluster_metadata.tags}"
  metadata_labels = "${module.cluster_metadata.labels}"

  min_master_version = "${var.cluster_min_master_version}"
  initial_node_count = "${var.cluster_initial_node_count}"
  additional_zones   = "${var.cluster_additional_zones}"

  daily_maintenance_window_start_time = "${var.cluster_daily_maintenance_window_start_time}"

  extra_oauth_scopes = "${var.cluster_extra_oauth_scopes}"
  disk_size_gb       = "${var.cluster_disk_size_gb}"
  disk_type          = "${var.cluster_disk_type}"
  machine_type       = "${var.cluster_machine_type}"
}
