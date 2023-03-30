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
  label_namespace = "testlns-"
}

locals {
  exp_name            = "testn-test_custom_label_namespace-testr"
  exp_domain          = "testp.testd.example.com"
  exp_fqdn            = "testn-test_custom_label_namespace-testr.testp.testd.example.com"
  exp_workspace       = "test_custom_label_namespace"
  exp_provider_name   = "testp"
  exp_provider_region = "testr"
  exp_label_namespace = "testlns-"
}

resource "test_assertions" "labels" {
  component = "labels"

  equal "scheme" {
    description = "labels have correct key/value pairs"
    got         = module.mut.labels
    want = {
      "${local.exp_label_namespace}cluster_name"            = local.exp_name
      "${local.exp_label_namespace}cluster_domain"          = local.exp_domain
      "${local.exp_label_namespace}cluster_fqdn"            = local.exp_fqdn
      "${local.exp_label_namespace}cluster_workspace"       = local.exp_workspace
      "${local.exp_label_namespace}cluster_provider_name"   = local.exp_provider_name
      "${local.exp_label_namespace}cluster_provider_region" = local.exp_provider_region
    }
  }
}

resource "test_assertions" "label_namespace" {
  component = "label_namespace"

  equal "scheme" {
    description = "returns the used label_namespace"
    got         = module.mut.label_namespace
    want        = local.exp_label_namespace
  }
}
