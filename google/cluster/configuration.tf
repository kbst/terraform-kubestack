locals {
  # apps config and merged ops config
  workspaces = {
    apps = "${var.configuration["apps"]}"
    ops  = "${merge(var.configuration["apps"], var.configuration["ops"])}"
  }

  # current workspace config
  cfg = "${local.workspaces[terraform.workspace]}"

  name_prefix = "${lookup(local.cfg, "name_prefix")}"

  base_domain = "${lookup(local.cfg, "base_domain")}"

  project_id = "${lookup(local.cfg, "project_id")}"

  region = "${lookup(local.cfg, "region")}"

  cluster_node_locations_lookup = "${lookup(local.cfg, "cluster_node_locations", "")}"
  cluster_node_locations        = "${split(",", local.cluster_node_locations_lookup)}"

  cluster_min_master_version = "${lookup(local.cfg, "cluster_min_master_version")}"

  cluster_initial_node_count = "${lookup(local.cfg, "cluster_initial_node_count")}"

  cluster_additional_zones_lookup = "${lookup(local.cfg, "cluster_additional_zones", "")}"
  cluster_additional_zones        = "${split(",", local.cluster_additional_zones_lookup)}"

  cluster_daily_maintenance_window_start_time = "${lookup(local.cfg, "cluster_daily_maintenance_window_start_time", "03:00")}"

  cluster_extra_oauth_scopes_lookup = "${lookup(local.cfg, "cluster_extra_oauth_scopes", "")}"
  cluster_extra_oauth_scopes        = "${split(",", local.cluster_extra_oauth_scopes_lookup)}"

  cluster_disk_size_gb = "${lookup(local.cfg, "cluster_disk_size_gb", 100)}"

  cluster_disk_type = "${lookup(local.cfg, "cluster_disk_type", "pd-standard")}"

  cluster_machine_type = "${lookup(local.cfg, "cluster_machine_type", "")}"
}
