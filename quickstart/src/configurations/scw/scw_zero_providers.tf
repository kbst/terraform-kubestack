provider "scaleway" {
  # The Scaleway provider requires organization_id and project_id to be set
  # explicitly so the target scope is captured in IaC rather than inferred
  # from the CLI config or SCW_DEFAULT_ORGANIZATION_ID / SCW_DEFAULT_PROJECT_ID
  # environment variables.
  organization_id = ""
  project_id      = ""

  # Region is also required. Set it to match the region configured in the
  # cluster module, e.g. "fr-par", "nl-ams", "pl-waw".
  region = ""
}

provider "kustomization" {
  alias          = "scw_zero"
  kubeconfig_raw = module.scw_zero.kubeconfig
}

locals {
  scw_zero_kubeconfig = yamldecode(module.scw_zero.kubeconfig)
}

provider "kubernetes" {
  alias = "scw_zero"

  host  = local.scw_zero_kubeconfig["clusters"][0]["cluster"]["server"]
  token = local.scw_zero_kubeconfig["users"][0]["user"]["token"]
  cluster_ca_certificate = base64decode(
    local.scw_zero_kubeconfig["clusters"][0]["cluster"]["certificate-authority-data"]
  )
}
