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

  resource_group = "${lookup(local.cfg, "resource_group")}"
}
