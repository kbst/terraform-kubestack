module "node_pool" {
  source = "./node-pool"

  cluster_metadata = module.cluster_metadata

  configuration = {
    (terraform.wokspace) = {
      project_id = local.project_id

      name = "default"

      location        = google_container_cluster.current.location
      node_locations  = local.cluster_node_locations
      location_policy = local.cluster_node_location_policy

      initial_node_count = local.cluster_initial_node_count
      min_node_count     = local.cluster_min_node_count
      max_node_count     = local.cluster_max_node_count

      disk_size_gb = local.cluster_disk_size_gb
      disk_type    = local.cluster_disk_type
      image_type   = local.cluster_image_type
      machine_type = local.cluster_machine_type

      preemptible  = local.cluster_preemptible
      auto_repair  = local.cluster_auto_repair
      auto_upgrade = local.cluster_auto_upgrade

      extra_oauth_scopes = local.cluster_extra_oauth_scopes

      node_workload_metadata_config = local.node_workload_metadata_config

      service_account_email = google_service_account.current.email

      labels = {}
    }
  }
}
