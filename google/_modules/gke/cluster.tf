resource "google_container_cluster" "current" {
  project = "${var.project}"
  name    = "${var.metadata_name}"

  location       = "${var.location}"
  node_locations = "${var.node_locations}"

  min_master_version = "${var.min_master_version}"

  remove_default_node_pool = "${var.remove_default_node_pool}"
  initial_node_count       = "${var.initial_node_count}"

  # Disable basic and client certificate auth
  # https://cloud.google.com/kubernetes-engine/docs/concepts/security-overview#control_plane_security
  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  network = "${google_compute_network.current.self_link}"

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
}
