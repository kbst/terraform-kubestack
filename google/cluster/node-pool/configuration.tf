module "configuration" {
  source = "../../../common/configuration"

  configuration = var.configuration
  base_key      = var.configuration_base_key
}

locals {
  # current workspace config
  cfg = module.configuration.merged[terraform.workspace]

  project_id = local.cfg["project_id"]

  name = lookup(local.cfg, "name")

  location       = local.cfg["location"]
  node_locations = local.cfg["node_locations"]

  initial_node_count = local.cfg["initial_node_count"]
  min_node_count     = local.cfg["min_node_count"]
  max_node_count     = local.cfg["max_node_count"]
  location_policy    = local.cfg["location_policy"] != null ? local.cfg["location_policy"] : "BALANCED"

  disk_size_gb = local.cfg["disk_size_gb"]
  disk_type    = local.cfg["disk_type"]
  image_type   = local.cfg["image_type"]
  machine_type = local.cfg["machine_type"]

  preemptible  = local.cfg["preemptible"] != null ? local.cfg["preemptible"] : false
  auto_repair  = local.cfg["auto_repair"] != null ? local.cfg["auto_repair"] : true
  auto_upgrade = local.cfg["auto_upgrade"] != null ? local.cfg["auto_upgrade"] : true

  taints = local.cfg["taints"]

  extra_oauth_scopes = local.cfg["extra_oauth_scopes"] != null ? local.cfg["extra_oauth_scopes"] : []

  node_workload_metadata_config = local.cfg["node_workload_metadata_config"] != null ? local.cfg["node_workload_metadata_config"] : "GKE_METADATA"

  service_account_email = local.cfg["service_account_email"]

  network_config = local.cfg["network_config"]

  instance_tags = local.cfg["instance_tags"]
}
