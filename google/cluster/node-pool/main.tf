module "node_pool" {
  source = "../../_modules/gke/node_pool"

  project = local.project_id

  location       = local.location
  node_locations = local.node_locations

  cluster_name = var.cluster_metadata["name"]
  pool_name    = local.name

  metadata_tags   = var.cluster_metadata["tags"]
  metadata_labels = var.cluster_metadata["labels"]

  initial_node_count = local.initial_node_count
  min_node_count     = local.min_node_count
  max_node_count     = local.max_node_count
  location_policy    = local.location_policy

  extra_oauth_scopes = local.extra_oauth_scopes

  disk_size_gb = local.disk_size_gb
  disk_type    = local.disk_type
  image_type   = local.image_type
  machine_type = local.machine_type

  preemptible  = local.preemptible
  auto_repair  = local.auto_repair
  auto_upgrade = local.auto_upgrade

  node_workload_metadata_config = local.node_workload_metadata_config

  taints        = local.taints
  instance_tags = local.instance_tags

  service_account_email                 = local.service_account_email
  disable_per_node_pool_service_account = local.service_account_email == null ? false : true

  network_config = local.network_config
}
