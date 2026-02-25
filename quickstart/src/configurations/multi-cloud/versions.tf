terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }

    kustomization = {
      source = "kbst/kustomization"
    }

    scaleway = {
      source = "scaleway/scaleway"
    }
  }

  required_version = ">= 0.15"
}
