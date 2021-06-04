module "configuration" {
  source = "../../common/configuration"

  configuration = var.configuration
  base_key      = var.configuration_base_key
}

locals {
  # current workspace config
  cfg = module.configuration.merged[terraform.workspace]

  name_prefix = local.cfg["name_prefix"]

  base_domain = local.cfg["base_domain"]

  # while we have the real region for GKE
  # we still hash and prefix it with gke-
  # to align with the local implementations
  # for AKS end EKS
  fake_region_hash = substr(sha256(local.cfg["region"]), 0, 7)
  fake_region      = "gke-${local.fake_region_hash}"

  http_port_default = terraform.workspace == "apps" ? 80 : 8080
  http_port         = lookup(local.cfg, "http_port", local.http_port_default)

  https_port_default = terraform.workspace == "apps" ? 443 : 8443
  https_port         = lookup(local.cfg, "https_port", local.https_port_default)

  disable_default_ingress = lookup(local.cfg, "disable_default_ingress", false)

  node_image = lookup(local.cfg, "node_image", null)

  # technically it should be min_node_count times number of AZs
  # but it seems better to keep node count low in the dev env
  node_count = lookup(local.cfg, "cluster_min_node_count", 1)
  nodes = [
    for node, _ in range(local.node_count) :
    "worker"
  ]
  extra_nodes = join(",", local.nodes)

}
