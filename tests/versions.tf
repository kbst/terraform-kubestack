terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }

    kustomization = {
      source = "kbst/kustomization"
    }
  }

  required_version = ">= 0.15"
}
