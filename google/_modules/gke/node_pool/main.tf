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

  dynamic "network_config" {
    for_each = var.network_config == null ? [] : [1]

    content {
        enable_private_nodes = var.network_config["enable_private_nodes"]
        create_pod_range     = var.network_config["create_pod_range"]
        pod_ipv4_cidr_block  = var.network_config["pod_ipv4_cidr_block"]
    }
  }

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

    labels = var.metadata_labels

    tags = concat(var.metadata_tags, var.instance_tags)

    workload_metadata_config {
      mode = var.node_workload_metadata_config
    }

    dynamic "guest_accelerator" {
      # Make sure to generate this only once
      for_each = var.guest_accelerator == null ? [] : [1]

      content {
        type               = guest_accelerator.value.type
        count              = guest_accelerator.value.count
        gpu_partition_size = guest_accelerator.value.gpu_partition_size
        gpu_sharing_config = guest_accelerator.value.gpu_sharing_config
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
  }

  management {
    auto_repair  = var.auto_repair
    auto_upgrade = var.auto_upgrade
  }
}
