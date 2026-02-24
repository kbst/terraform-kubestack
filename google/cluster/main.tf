module "configuration" {
  source        = "../../common/configuration"
  configuration = var.configuration
  base_key      = var.configuration_base_key
}

locals {
  cfg = module.configuration.merged[terraform.workspace]
}

module "cluster_metadata" {
  source = "../../common/metadata"

  name_prefix = local.cfg.name_prefix
  base_domain = local.cfg.base_domain

  provider_name   = "gcp"
  provider_region = local.cfg.region
}

resource "google_container_cluster" "current" {
  project = local.cfg.project_id
  name    = module.cluster_metadata.name

  deletion_protection = local.cfg.deletion_protection

  location       = local.cfg.region
  node_locations = try(coalesce(local.cfg.cluster_node_locations, null), [])

  min_master_version = local.cfg.cluster_min_master_version

  release_channel {
    channel = try(coalesce(local.cfg.cluster_release_channel, null), "STABLE")
  }

  remove_default_node_pool = true
  initial_node_count       = 1

  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  network = google_compute_network.current.self_link

  dynamic "workload_identity_config" {
    for_each = try(coalesce(local.cfg.disable_workload_identity, null), false) == false ? toset([1]) : toset([])
    content {
      workload_pool = "${local.cfg.project_id}.svc.id.goog"
    }
  }

  dynamic "database_encryption" {
    for_each = local.cfg.cluster_database_encryption_key_name != null ? [1] : []
    content {
      state    = "ENCRYPTED"
      key_name = local.cfg.cluster_database_encryption_key_name
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
      for_each = local.cfg.enable_gcs_fuse_csi_driver != null ? [1] : []

      content {
        enabled = local.cfg.enable_gcs_fuse_csi_driver
      }
    }
  }

  network_policy {
    enabled = true
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = try(coalesce(local.cfg.cluster_daily_maintenance_window_start_time, null), "03:00")
    }

    dynamic "maintenance_exclusion" {
      for_each = try(local.cfg.cluster_maintenance_exclusion.start_time, "") != "" ? [1] : []

      content {
        start_time     = try(local.cfg.cluster_maintenance_exclusion.start_time, "")
        end_time       = try(local.cfg.cluster_maintenance_exclusion.end_time, "")
        exclusion_name = try(local.cfg.cluster_maintenance_exclusion.name, "")

        exclusion_options {
          scope = try(local.cfg.cluster_maintenance_exclusion.scope, "")
        }
      }
    }
  }

  dynamic "master_authorized_networks_config" {
    for_each = local.cfg.master_authorized_networks_config_cidr_blocks == null ? [] : [1]

    content {
      dynamic "cidr_blocks" {
        for_each = local.cfg.master_authorized_networks_config_cidr_blocks

        content {
          cidr_block   = cidr_blocks.value
          display_name = "terraform-kubestack_${cidr_blocks.value}"
        }
      }
    }
  }

  logging_config {
    enable_components = try(coalesce(local.cfg.logging_config.enable_components, null), ["SYSTEM_COMPONENTS", "WORKLOADS"])
  }

  monitoring_config {
    enable_components = try(coalesce(local.cfg.monitoring_config.enable_components, null), ["SYSTEM_COMPONENTS"])
  }

  private_cluster_config {
    enable_private_nodes    = try(coalesce(local.cfg.enable_private_nodes, null), true)
    enable_private_endpoint = try(coalesce(local.cfg.enable_private_endpoint, null), false)
    master_ipv4_cidr_block  = try(coalesce(local.cfg.master_cidr_block, null), "172.16.0.32/28")
  }

  dynamic "ip_allocation_policy" {
    for_each = try(coalesce(local.cfg.enable_private_nodes, null), true) ? [1] : []

    content {
      cluster_ipv4_cidr_block  = local.cfg.cluster_ipv4_cidr_block
      services_ipv4_cidr_block = local.cfg.services_ipv4_cidr_block
    }
  }

  enable_intranode_visibility = try(coalesce(local.cfg.enable_intranode_visibility, null), false)
  enable_tpu                  = try(coalesce(local.cfg.enable_tpu, null), false)
}
