data "template_file" "kubeconfig" {
  template = var.template_string

  vars = var.template_vars
}

provider "kustomization" {
  kubeconfig_raw = data.template_file.kubeconfig.rendered
}
