locals {
  base_oauth_scopes = [
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring",
    "https://www.googleapis.com/auth/servicecontrol",
    "https://www.googleapis.com/auth/service.management.readonly",
    "https://www.googleapis.com/auth/trace.append",
  ]

  oauth_scopes = "${concat(local.base_oauth_scopes, var.extra_oauth_scopes)}"
}

resource "google_container_cluster" "current" {
  project = "${var.project}"
  name    = "${var.metadata_name}"
  region  = "${var.region}"

  min_master_version = "${var.min_master_version}"

  initial_node_count = "${var.initial_node_count}"

  additional_zones = ["${var.additional_zones}"]

  #
  #
  # Addon config
  addons_config {
    http_load_balancing {
      disabled = true
    }

    horizontal_pod_autoscaling {
      disabled = false
    }

    kubernetes_dashboard {
      disabled = true
    }

    network_policy_config {
      disabled = false
    }
  }

  network_policy {
    enabled = true
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "${var.daily_maintenance_window_start_time}"
    }
  }

  #
  #
  # Node config
  node_config {
    workload_metadata_config {
      node_metadata = "SECURE"
    }

    oauth_scopes = "${local.oauth_scopes}"

    disk_size_gb = "${var.disk_size_gb}"
    disk_type    = "${var.disk_type}"

    image_type   = "COS"
    machine_type = "${var.machine_type}"

    labels = "${var.metadata_labels}"

    tags = "${var.metadata_tags}"
  }
}
