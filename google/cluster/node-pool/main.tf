module "node_pool" {
  source = "../../_modules/gke/node_pool"

  project = local.cfg["project_id"]

  cluster_name = var.cluster_metadata["name"]
  pool_name    = local.cfg["name"]

  metadata_tags   = var.cluster_metadata["tags"]
  metadata_labels = var.cluster_metadata["labels"]

  initial_node_count = local.cfg["initial_node_count"]
  min_node_count     = local.cfg["min_node_count"]
  max_node_count     = local.cfg["max_node_count"]
  location_policy    = local.cfg["location_policy"]

  location       = local.cfg["location"]
  node_locations = local.cfg["node_locations"]


  extra_oauth_scopes = local.cfg["extra_oauth_scopes"] != null ? local.cfg["extra_oauth_scopes"] : []

  disk_size_gb = local.cfg["disk_size_gb"]
  disk_type    = local.cfg["disk_type"]
  image_type   = local.cfg["image_type"]
  machine_type = local.cfg["machine_type"]

  preemptible  = local.cfg["preemptible"] != null ? local.cfg["preemptible"] : false
  auto_repair  = local.cfg["auto_repair"] != null ? local.cfg["auto_repair"] : true
  auto_upgrade = local.cfg["auto_upgrade"] != null ? local.cfg["auto_upgrade"] : true

  node_workload_metadata_config = local.cfg["node_workload_metadata_config"] != null ? local.cfg["node_workload_metadata_config"] : "GKE_METADATA"

  taint = local.cfg["taint"]

  service_account_email                 = local.cfg["service_account_email"]
  disable_per_node_pool_service_account = local.cfg["service_account_email"] == null ? false : true
}
