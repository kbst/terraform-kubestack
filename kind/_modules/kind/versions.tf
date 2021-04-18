terraform {
  required_providers {
    kind = {
      # https://registry.terraform.io/providers/kyma-incubator/kind/latest
      source  = "kyma-incubator/kind"
      version = ">= 0.0.7"
    }
  }

  required_version = ">= 0.13"
}
