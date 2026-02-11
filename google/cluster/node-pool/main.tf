resource "google_container_node_pool" "current" {
  name     = local.name
  project  = local.project_id
  cluster  = var.cluster_metadata["name"]
  location = local.location

  initial_node_count = local.initial_node_count

  autoscaling {
    min_node_count  = local.min_node_count
    max_node_count  = local.max_node_count
    location_policy = local.location_policy
  }

  node_locations = local.node_locations

  dynamic "network_config" {
    for_each = local.network_config == null ? [] : [1]

    content {
        enable_private_nodes = local.network_config["enable_private_nodes"]
        create_pod_range     = local.network_config["create_pod_range"]
        pod_ipv4_cidr_block  = local.network_config["pod_ipv4_cidr_block"]
    }
  }

  #
  #
  # Node config
  node_config {
    service_account = local.service_account_email == null ? google_service_account.current[0].email : local.service_account_email

    oauth_scopes = local.oauth_scopes

    disk_size_gb = local.disk_size_gb
    disk_type    = local.disk_type

    image_type   = local.image_type
    machine_type = local.machine_type
    preemptible  = local.preemptible

    labels = merge(local.labels, var.cluster_metadata["labels"])

    tags = concat(var.cluster_metadata["tags"], local.instance_tags)

    workload_metadata_config {
      mode = local.node_workload_metadata_config
    }

    dynamic "guest_accelerator" {
      # Make sure to generate this only once
      for_each = local.guest_accelerator == null ? [] : [1]

      content {
        type  = local.guest_accelerator.type
        count = local.guest_accelerator.count

        dynamic "gpu_sharing_config" {
          for_each = local.guest_accelerator.gpu_sharing_config == null ? [] : [1]

          content {
            gpu_sharing_strategy       = local.guest_accelerator.gpu_sharing_config.gpu_sharing_strategy
            max_shared_clients_per_gpu = local.guest_accelerator.gpu_sharing_config.max_shared_clients_per_gpu
          }
        }
      }
    }

    dynamic "taint" {
      for_each = local.taints == null ? [] : local.taints

      content {
        key    = taint.value["key"]
        value  = taint.value["value"]
        effect = taint.value["effect"]
      }
    }

    dynamic "ephemeral_storage_local_ssd_config" {
      for_each = local.ephemeral_storage_local_ssd_config == null ? [] : [1]

      content {
        local_ssd_count = local.ephemeral_storage_local_ssd_config.local_ssd_count
      }
    }
  }

  management {
    auto_repair  = local.auto_repair
    auto_upgrade = local.auto_upgrade
  }
}
