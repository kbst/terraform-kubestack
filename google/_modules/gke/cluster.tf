resource "google_container_cluster" "current" {
  project = var.project
  name    = var.metadata_name

  deletion_protection = var.deletion_protection

  location       = var.location
  node_locations = var.node_locations

  min_master_version = var.min_master_version

  release_channel {
    channel = var.release_channel
  }

  remove_default_node_pool = var.remove_default_node_pool
  initial_node_count       = var.initial_node_count

  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  network = google_compute_network.current.self_link

  dynamic "workload_identity_config" {
    for_each = var.disable_workload_identity == false ? toset([1]) : toset([])
    content {
      workload_pool = "${var.project}.svc.id.goog"
    }
  }

  dynamic "database_encryption" {
    for_each = var.cluster_database_encryption_key_name != null ? toset([1]) : toset([])
    content {
      state    = "ENCRYPTED"
      key_name = var.cluster_database_encryption_key_name
    }
  }

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

    network_policy_config {
      disabled = false
    }

    dynamic "gcs_fuse_csi_driver_config" {
      for_each = var.enable_gcs_fuse_csi_driver != null ? [1] : []

      content {
        enabled = var.enable_gcs_fuse_csi_driver
      }
    }
  }

  network_policy {
    enabled = true
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = var.daily_maintenance_window_start_time
    }

    dynamic "maintenance_exclusion" {
      for_each = var.maintenance_exclusion_start_time != null ? [1] : []

      content {
        start_time     = var.maintenance_exclusion_start_time
        end_time       = var.maintenance_exclusion_end_time
        exclusion_name = var.maintenance_exclusion_name

        exclusion_options {
          scope = var.maintenance_exclusion_scope
        }
      }
    }
  }

  dynamic "master_authorized_networks_config" {
    for_each = var.master_authorized_networks_config_cidr_blocks == null ? toset([]) : toset([1])

    content {
      dynamic "cidr_blocks" {
        for_each = var.master_authorized_networks_config_cidr_blocks

        content {
          cidr_block   = cidr_blocks.value
          display_name = "terraform-kubestack_${cidr_blocks.value}"
        }
      }
    }
  }

  logging_config {
    enable_components = var.logging_config_enable_components
  }

  monitoring_config {
    enable_components = var.monitoring_config_enable_components
  }

  private_cluster_config {
    enable_private_nodes    = var.enable_private_nodes
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.master_cidr_block
  }

  dynamic "ip_allocation_policy" {
    for_each = var.enable_private_nodes ? toset([1]) : []

    content {
      cluster_ipv4_cidr_block  = var.cluster_ipv4_cidr_block
      services_ipv4_cidr_block = var.services_ipv4_cidr_block
    }
  }

  enable_intranode_visibility = var.enable_intranode_visibility
  enable_tpu                  = var.enable_tpu
}
