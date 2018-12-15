locals {
  cluster_dir = "${path.cwd}/clusters/${var.metadata_fqdn}"
}

data "template_file" "kubeconfig" {
  template = "${var.template_string}"

  vars = "${var.template_vars}"
}

resource "local_file" "kubeconfig" {
  content  = "${data.template_file.kubeconfig.rendered}"
  filename = "${local.cluster_dir}/kubeconfig"
}
