data "template_file" "kubeconfig" {
  template = var.template_string

  vars = var.template_vars
}

provider "kustomization" {
  kubeconfig_raw = data.template_file.kubeconfig.rendered
}

data "kustomization" "current" {
  # path to kustomization directory
  path = var.manifest_path
}

resource "kustomization_resource" "current" {
  for_each = data.kustomization.current.ids

  manifest = data.kustomization.current.manifests[each.value]
}
