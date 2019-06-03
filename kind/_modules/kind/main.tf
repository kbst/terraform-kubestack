data "template_file" "config" {
  template = "${file("${path.module}/templates/kind_config.yaml")}"

  vars = {
    node_roles = "${var.node_roles}"
  }
}

locals {
  kind_config_path = "${path.cwd}/clusters/${var.metadata_fqdn}/kind_config.yaml"
}

resource "local_file" "config" {
  content  = "${data.template_file.config.rendered}"
  filename = "${local.kind_config_path}"
}

resource "null_resource" "cluster" {
  triggers = {
    node_roles = "${base64sha256(data.template_file.config.rendered)}"
  }

  provisioner "local-exec" {
    command = "kind create cluster --wait 10m --name ${var.metadata_name} --config ${local.kind_config_path}"
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "kind delete cluster --name ${var.metadata_name}"
  }

  depends_on = ["local_file.config"]
}
