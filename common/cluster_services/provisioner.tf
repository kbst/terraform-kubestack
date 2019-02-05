data "external" "kustomize_build" {
  program = ["sh", "${path.module}/kustomize_build.sh"]

  query = {
    build_path  = "${local.build_path}"
    output_path = "${local.cluster_dir}"
    output_file = "${local.output_file}"
  }
}

data "template_file" "kubeconfig" {
  template = "${var.template_string}"

  vars = "${var.template_vars}"
}

resource "null_resource" "cluster_services" {
  triggers {
    checksum = "${data.external.kustomize_build.result["checksum"]}"
  }

  provisioner "local-exec" {
    command = "echo '${data.template_file.kubeconfig.rendered}' > ${local.kubeconfig_path} && kubectl apply -f ${local.cluster_dir}/${local.output_file}"

    environment {
      KUBECONFIG = "${local.kubeconfig_path}"
    }
  }
}
