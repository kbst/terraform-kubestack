module "cluster_metadata" {
  source = "../../common/metadata"

  name_prefix = local.name_prefix
  base_domain = local.base_domain

  provider_name   = "gcp"
  provider_region = local.region
}

resource "google_container_cluster" "current" {
  project = local.project_id
  name    = module.cluster_metadata.name

  deletion_protection = local.deletion_protection

  location       = local.region
  node_locations = local.cluster_node_locations

  min_master_version = local.cluster_min_master_version

  release_channel {
    channel = local.cluster_release_channel
  }

  remove_default_node_pool = local.remove_default_node_pool
  initial_node_count       = local.cluster_initial_node_count

  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  network = google_compute_network.current.self_link

  dynamic "workload_identity_config" {
    for_each = local.disable_workload_identity == false ? toset([1]) : toset([])
    content {
      workload_pool = "${local.project_id}.svc.id.goog"
    }
  }

  dynamic "database_encryption" {
    for_each = local.cluster_database_encryption_key_name != null ? toset([1]) : toset([])
    content {
      state    = "ENCRYPTED"
      key_name = local.cluster_database_encryption_key_name
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
      for_each = local.enable_gcs_fuse_csi_driver != null ? [1] : []

      content {
        enabled = local.enable_gcs_fuse_csi_driver
      }
    }
  }

  network_policy {
    enabled = true
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = local.cluster_daily_maintenance_window_start_time
    }

    dynamic "maintenance_exclusion" {
      for_each = local.cluster_maintenance_exclusion_start_time != "" ? [1] : []

      content {
        start_time     = local.cluster_maintenance_exclusion_start_time
        end_time       = local.cluster_maintenance_exclusion_end_time
        exclusion_name = local.cluster_maintenance_exclusion_name

        exclusion_options {
          scope = local.cluster_maintenance_exclusion_scope
        }
      }
    }
  }

  dynamic "master_authorized_networks_config" {
    for_each = local.master_authorized_networks_config_cidr_blocks == null ? toset([]) : toset([1])

    content {
      dynamic "cidr_blocks" {
        for_each = local.master_authorized_networks_config_cidr_blocks

        content {
          cidr_block   = cidr_blocks.value
          display_name = "terraform-kubestack_${cidr_blocks.value}"
        }
      }
    }
  }

  logging_config {
    enable_components = local.logging_config_enable_components
  }

  monitoring_config {
    enable_components = local.monitoring_config_enable_components
  }

  private_cluster_config {
    enable_private_nodes    = local.enable_private_nodes
    enable_private_endpoint = false
    master_ipv4_cidr_block  = local.master_cidr_block
  }

  dynamic "ip_allocation_policy" {
    for_each = local.enable_private_nodes ? toset([1]) : []

    content {
      cluster_ipv4_cidr_block  = local.cluster_ipv4_cidr_block
      services_ipv4_cidr_block = local.services_ipv4_cidr_block
    }
  }

  enable_intranode_visibility = local.enable_intranode_visibility
  enable_tpu                  = local.enable_tpu
}
