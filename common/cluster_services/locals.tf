locals {
  fqdn_label   = "${var.label_namespace}cluster_fqdn"
  cluster_fqdn = var.metadata_labels[local.fqdn_label]
  cluster_dir  = "${path.cwd}/clusters/${local.cluster_fqdn}"

  workspace_label = "${var.label_namespace}cluster_workspace"
  workspace       = var.metadata_labels[local.workspace_label]
  build_path      = "manifests/overlays/${var.cluster_type}/${local.workspace}"

  output_file = "cluster_services.yaml"

  kubeconfig_path = "${local.cluster_dir}/kubeconfig"
}

