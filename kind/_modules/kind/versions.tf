
terraform {
  required_providers {
    kind = {
      source  = "kyma-incubator/kind"
      version = "0.0.6"
    }
  }

  required_version = ">= 0.13"
}
