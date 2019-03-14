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

  region = "${lookup(local.cfg, "region")}"

  cluster_min_master_version = "${lookup(local.cfg, "cluster_min_master_version")}"

  cluster_initial_node_count = "${lookup(local.cfg, "cluster_initial_node_count")}"

  cluster_machine_type = "${lookup(local.cfg, "cluster_machine_type", "")}"
}
