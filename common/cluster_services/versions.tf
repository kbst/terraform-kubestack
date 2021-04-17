
terraform {
  required_providers {
    kustomization = {
      # https://registry.terraform.io/providers/kbst/kustomization/latest
      source  = "kbst/kustomization"
      version = ">= 0.3.1"
    }

    template = {
      # https://registry.terraform.io/providers/hashicorp/template/latest
      source  = "hashicorp/template"
      version = ">= 2.2.0"
    }
  }

  required_version = ">= 0.13"
}
