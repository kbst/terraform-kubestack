locals {
  workspace_label = "${var.label_namespace}cluster_workspace"
  workspace       = var.metadata_labels[local.workspace_label]
  build_path      = "manifests/overlays/${var.cluster_type}/${local.workspace}"
}

data "template_file" "kubeconfig" {
  template = var.template_string

  vars = var.template_vars
}

provider "kustomization" {
  kubeconfig_raw = data.template_file.kubeconfig.rendered
}

data "kustomization" "current" {
  # path to kustomization directory
  path = local.build_path
}

resource "kustomization_resource" "current" {
  for_each = data.kustomization.current.ids

  manifest = data.kustomization.current.manifests[each.value]
}
