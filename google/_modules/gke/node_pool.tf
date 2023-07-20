module "node_pool" {
  source = "./node_pool"

  project  = var.project
  location = google_container_cluster.current.location

  cluster_name = google_container_cluster.current.name
  pool_name    = "default"

  service_account_email                 = google_service_account.current.email
  disable_per_node_pool_service_account = true

  metadata_tags   = var.metadata_tags
  metadata_labels = var.metadata_labels

  initial_node_count = var.initial_node_count
  min_node_count     = var.min_node_count
  max_node_count     = var.max_node_count
  location_policy    = var.location_policy

  extra_oauth_scopes = var.extra_oauth_scopes

  disk_size_gb = var.disk_size_gb
  disk_type    = var.disk_type
  image_type   = var.image_type
  machine_type = var.machine_type

  # Whether to use preemptible nodes for this node pool
  preemptible = var.preemptible
  # Whether the nodes will be automatically repaired
  auto_repair = var.auto_repair
  # Whether the nodes will be automatically upgraded
  auto_upgrade = var.auto_upgrade

  node_workload_metadata_config = var.node_workload_metadata_config
}
