module "node_pool" {
  source = "./node-pool"

  cluster = google_container_cluster.current

  configuration = {
    (terraform.workspace) = {
      project_id     = local.cfg.project_id
      location       = google_container_cluster.current.location
      node_locations = local.cfg.cluster_node_locations
      name           = "default"

      service_account_email = google_service_account.current.email

      initial_node_count = try(coalesce(local.cfg.default_node_pool.initial_node_count, null), 1)
      min_node_count     = try(coalesce(local.cfg.default_node_pool.min_node_count, null), 1)
      max_node_count     = try(coalesce(local.cfg.default_node_pool.max_node_count, null), 1)
      location_policy    = try(local.cfg.default_node_pool.node_location_policy, null)

      extra_oauth_scopes = try(coalesce(local.cfg.default_node_pool.extra_oauth_scopes, null), [])

      disk_size_gb = try(coalesce(local.cfg.default_node_pool.disk_size_gb, null), 100)
      disk_type    = try(coalesce(local.cfg.default_node_pool.disk_type, null), "pd-standard")
      image_type   = try(coalesce(local.cfg.default_node_pool.image_type, null), "COS_containerd")
      machine_type = try(coalesce(local.cfg.default_node_pool.machine_type, null), "")

      preemptible  = try(coalesce(local.cfg.default_node_pool.preemptible, null), false)
      auto_repair  = try(coalesce(local.cfg.default_node_pool.auto_repair, null), true)
      auto_upgrade = try(coalesce(local.cfg.default_node_pool.auto_upgrade, null), true)

      node_workload_metadata_config = try(coalesce(local.cfg.node_workload_metadata_config, null), "GKE_METADATA")

      taints        = try(coalesce(local.cfg.default_node_pool.taints, null), toset([]))
      instance_tags = try(coalesce(local.cfg.default_node_pool.instance_tags, null), [])
      labels        = try(coalesce(local.cfg.default_node_pool.labels, null), {})

      ephemeral_storage_local_ssd_config = try(local.cfg.default_node_pool.ephemeral_storage_local_ssd_config, null)
      network_config                     = try(local.cfg.default_node_pool.network_config, null)
      guest_accelerator                  = null
    }
  }
  configuration_base_key = terraform.workspace

  cluster_metadata = module.cluster_metadata
}
