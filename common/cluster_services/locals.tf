locals {
  cluster_fqdn = "${var.metadata_labels["kubestack.com/cluster_fqdn"]}"
  cluster_dir  = "${path.cwd}/clusters/${local.cluster_fqdn}"

  workspace  = "${var.metadata_labels["kubestack.com/cluster_workspace"]}"
  build_path = "manifests/overlays/${var.cluster_type}/${local.workspace}"

  output_file = "cluster_services.yaml"

  kubeconfig_path = "${local.cluster_dir}/kubeconfig"
}
