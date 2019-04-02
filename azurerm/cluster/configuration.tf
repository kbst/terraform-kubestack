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

  worker_nodes_name = "${lookup(local.cfg, "worker_nodes_name")}"

  worker_nodes_count = "${lookup(local.cfg, "worker_nodes_count")}"

  worker_nodes_vm_size = "${lookup(local.cfg, "worker_nodes_vm_size")}"

  worker_nodes_os_type = "${lookup(local.cfg, "worker_nodes_os_type")}"

  worker_nodes_os_disk_size_gb = "${lookup(local.cfg, "worker_nodes_os_disk_size_gb")}"
}
