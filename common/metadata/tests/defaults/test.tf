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
}

locals {
  exp_name            = "testn-test_defaults-testr"
  exp_domain          = "testp.testd.example.com"
  exp_fqdn            = "testn-test_defaults-testr.testp.testd.example.com"
  exp_workspace       = "test_defaults"
  exp_provider_name   = "testp"
  exp_provider_region = "testr"
}

resource "test_assertions" "name" {
  component = "name"

  equal "scheme" {
    description = "name concatenates name_prefix, workspace and provider_region"
    got         = module.mut.name
    want        = local.exp_name
  }
}

resource "test_assertions" "domain" {
  component = "domain"

  equal "scheme" {
    description = "domain concatenates name and base_domain"
    got         = module.mut.domain
    want        = local.exp_domain
  }
}

resource "test_assertions" "fqdn" {
  component = "fqdn"

  equal "scheme" {
    description = "fqdn concatenates name and domain"
    got         = module.mut.fqdn
    want        = local.exp_fqdn
  }
}

resource "test_assertions" "labels" {
  component = "labels"

  equal "scheme" {
    description = "labels have correct key/value pairs"
    got         = module.mut.labels
    want = {
      "kubestack.com/cluster_name"            = local.exp_name
      "kubestack.com/cluster_domain"          = local.exp_domain
      "kubestack.com/cluster_fqdn"            = local.exp_fqdn
      "kubestack.com/cluster_workspace"       = local.exp_workspace
      "kubestack.com/cluster_provider_name"   = local.exp_provider_name
      "kubestack.com/cluster_provider_region" = local.exp_provider_region
    }
  }
}

resource "test_assertions" "label_namespace" {
  component = "label_namespace"

  equal "scheme" {
    description = "returns the used label_namespace"
    got         = module.mut.label_namespace
    want        = "kubestack.com/"
  }
}

resource "test_assertions" "tags" {
  component = "tags"

  equal "scheme" {
    description = "returns the used label_namespace"
    got         = module.mut.tags
    want = [
      local.exp_name,
      local.exp_workspace,
      local.exp_provider_name,
      local.exp_provider_region,
    ]
  }
}
