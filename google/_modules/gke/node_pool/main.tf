resource "google_container_node_pool" "current" {
  name     = var.pool_name
  project  = var.project
  cluster  = var.cluster_name
  location = var.location

  initial_node_count = var.initial_node_count

  autoscaling {
    min_node_count  = var.min_node_count
    max_node_count  = var.max_node_count
    location_policy = var.location_policy
  }

  node_locations = var.node_locations

  #
  #
  # Node config
  node_config {
    service_account = var.disable_per_node_pool_service_account ? var.service_account_email : google_service_account.current[0].email

    oauth_scopes = local.oauth_scopes

    disk_size_gb = var.disk_size_gb
    disk_type    = var.disk_type

    image_type   = var.image_type
    machine_type = var.machine_type
    preemptible  = var.preemptible

    labels = merge(var.labels, var.metadata_labels)

    tags = var.metadata_tags

    workload_metadata_config {
      mode = var.node_workload_metadata_config
    }

    dynamic "guest_accelerator" {
      # Make sure to generate this only once
      for_each = var.guest_accelerator == null ? [] : [1]

      content {
        type  = var.guest_accelerator.type
        count = var.guest_accelerator.count

        dynamic "gpu_sharing_config" {
          for_each = var.guest_accelerator.gpu_sharing_config == null ? [] : [1]

          content {
            gpu_sharing_strategy       = var.guest_accelerator.gpu_sharing_config.gpu_sharing_strategy
            max_shared_clients_per_gpu = var.guest_accelerator.gpu_sharing_config.max_shared_clients_per_gpu
          }
        }
      }
    }

    dynamic "taint" {
      for_each = var.taints == null ? [] : var.taints

      content {
        key    = taint.value["key"]
        value  = taint.value["value"]
        effect = taint.value["effect"]
      }
    }

    dynamic "ephemeral_storage_local_ssd_config" {
      for_each = var.ephemeral_storage_local_ssd_config == null ? [] : [1]

      content {
        local_ssd_count = var.ephemeral_storage_local_ssd_config.local_ssd_count
      }
    }
  }

  management {
    auto_repair  = var.auto_repair
    auto_upgrade = var.auto_upgrade
  }
}
