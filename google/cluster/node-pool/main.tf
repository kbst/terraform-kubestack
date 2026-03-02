module "configuration" {
  source        = "../../../common/configuration"
  configuration = var.configuration
  base_key      = var.configuration_base_key
}

locals {
  cfg = module.configuration.merged[terraform.workspace]

  disable_per_node_pool_service_account = local.cfg.service_account_email == null ? false : true

  base_oauth_scopes = [
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring",
    "https://www.googleapis.com/auth/servicecontrol",
    "https://www.googleapis.com/auth/service.management.readonly",
    "https://www.googleapis.com/auth/trace.append",
  ]

  oauth_scopes = compact(concat(local.base_oauth_scopes, try(coalesce(local.cfg.extra_oauth_scopes, null), [])))
}

resource "google_container_node_pool" "current" {
  name     = local.cfg.name
  project  = local.cfg.project_id
  cluster  = var.cluster.name
  location = local.cfg.location

  lifecycle {
    precondition {
      condition     = local.cfg.location != null
      error_message = "missing required configuration attribute: location"
    }

    precondition {
      condition     = local.cfg.machine_type != null
      error_message = "missing required configuration attribute: machine_type"
    }

    precondition {
      condition     = local.cfg.min_node_count != null
      error_message = "missing required configuration attribute: min_node_count"
    }

    precondition {
      condition     = local.cfg.max_node_count != null
      error_message = "missing required configuration attribute: max_node_count"
    }
  }

  initial_node_count = local.cfg.initial_node_count

  autoscaling {
    min_node_count  = local.cfg.min_node_count
    max_node_count  = local.cfg.max_node_count
    location_policy = try(coalesce(local.cfg.location_policy, null), "BALANCED")
  }

  node_locations = try(coalesce(local.cfg.node_locations, null), [])

  dynamic "network_config" {
    for_each = local.cfg.network_config == null ? [] : [1]

    content {
      enable_private_nodes = local.cfg.network_config.enable_private_nodes
      create_pod_range     = local.cfg.network_config.create_pod_range
      pod_ipv4_cidr_block  = local.cfg.network_config.pod_ipv4_cidr_block
    }
  }

  #
  #
  # Node config
  node_config {
    service_account = local.disable_per_node_pool_service_account ? local.cfg.service_account_email : google_service_account.current[0].email

    oauth_scopes = local.oauth_scopes

    disk_size_gb = try(coalesce(local.cfg.disk_size_gb, null), 100)
    disk_type    = try(coalesce(local.cfg.disk_type, null), "pd-balanced")

    image_type   = try(coalesce(local.cfg.image_type, null), "COS_CONTAINERD")
    machine_type = local.cfg.machine_type
    preemptible  = try(coalesce(local.cfg.preemptible, null), false)

    labels = merge(try(coalesce(local.cfg.labels, null), {}), var.cluster_metadata.labels)

    tags = concat(var.cluster_metadata.tags, try(coalesce(local.cfg.instance_tags, null), []))

    workload_metadata_config {
      mode = try(coalesce(local.cfg.node_workload_metadata_config, null), "GKE_METADATA")
    }

    dynamic "guest_accelerator" {
      # Make sure to generate this only once
      for_each = local.cfg.guest_accelerator == null ? [] : [1]

      content {
        type  = local.cfg.guest_accelerator.type
        count = local.cfg.guest_accelerator.count

        dynamic "gpu_sharing_config" {
          for_each = local.cfg.guest_accelerator.gpu_sharing_config == null ? [] : [1]

          content {
            gpu_sharing_strategy       = local.cfg.guest_accelerator.gpu_sharing_config.gpu_sharing_strategy
            max_shared_clients_per_gpu = local.cfg.guest_accelerator.gpu_sharing_config.max_shared_clients_per_gpu
          }
        }
      }
    }

    dynamic "taint" {
      for_each = try(coalesce(local.cfg.taints, null), toset([])) == null ? [] : try(coalesce(local.cfg.taints, null), toset([]))

      content {
        key    = taint.value.key
        value  = taint.value.value
        effect = taint.value.effect
      }
    }

    dynamic "ephemeral_storage_local_ssd_config" {
      for_each = local.cfg.ephemeral_storage_local_ssd_config == null ? [] : [1]

      content {
        local_ssd_count = local.cfg.ephemeral_storage_local_ssd_config.local_ssd_count
      }
    }
  }

  management {
    auto_repair  = try(coalesce(local.cfg.auto_repair, null), true)
    auto_upgrade = try(coalesce(local.cfg.auto_upgrade, null), true)
  }
}
