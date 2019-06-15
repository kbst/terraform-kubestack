resource "google_container_node_pool" "current" {
  name     = "${var.pool_name}"
  project  = "${var.project}"
  cluster  = "${var.metadata_name}"
  location = "${var.location}"

  initial_node_count = "${var.initial_node_count}"

  autoscaling = {
    min_node_count = "${var.min_node_count}"
    max_node_count = "${var.max_node_count}"
  }

  #
  #
  # Node config
  node_config {
    service_account = "${var.service_account_email}"

    oauth_scopes = "${local.oauth_scopes}"

    disk_size_gb = "${var.disk_size_gb}"
    disk_type    = "${var.disk_type}"

    image_type   = "${var.image_type}"
    machine_type = "${var.machine_type}"
    preemptible  = "${var.preemptible}"

    labels = "${var.metadata_labels}"

    tags = "${var.metadata_tags}"
  }

  management {
    auto_repair  = "${var.auto_repair}"
    auto_upgrade = "${var.auto_upgrade}"
  }
}
