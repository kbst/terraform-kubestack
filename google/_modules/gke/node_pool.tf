module "node_pool" {
  source = "./node_pool"

  project  = "${var.project}"
  location = "${google_container_cluster.current.location}"

  pool_name             = "default"
  service_account_email = "${google_service_account.current.email}"

  metadata_name   = "${var.metadata_name}"
  metadata_fqdn   = "${var.metadata_fqdn}"
  metadata_tags   = "${var.metadata_tags}"
  metadata_labels = "${var.metadata_labels}"

  initial_node_count = "${var.initial_node_count}"
  min_node_count     = "${var.min_node_count}"
  max_node_count     = "${var.max_node_count}"

  extra_oauth_scopes = "${var.extra_oauth_scopes}"

  disk_size_gb = "${var.disk_size_gb}"
  disk_type    = "${var.disk_type}"
  image_type   = "${var.image_type}"
  machine_type = "${var.machine_type}"
}
