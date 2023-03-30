terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }
  }
}

module "mut" {
  source = "../.."

  name_prefix     = "testn"
  base_domain     = "testd.example.com"
  provider_name   = "testp"
  provider_region = "testr"
  workspace       = "testw"
}

locals {
  exp_workspace = "testw"
  exp_name      = "testn-${local.exp_workspace}-testr"
}

resource "test_assertions" "name" {
  component = "name"

  equal "scheme" {
    description = "name concatenates name_prefix, workspace and provider_region"
    got         = module.mut.name
    want        = local.exp_name
  }
}

resource "test_assertions" "workspace_label" {
  component = "workspace_label"

  equal "scheme" {
    description = "labels have correct key/value pairs"
    got         = module.mut.labels["kubestack.com/cluster_workspace"]
    want        = local.exp_workspace
  }
}

resource "test_assertions" "workspace_tag" {
  component = "workspace_tag"

  check "contains" {
    description = "check the workspace is one of the tags"
    condition   = contains(module.mut.tags, local.exp_workspace)
  }
}
