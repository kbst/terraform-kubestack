terraform {
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
    }

    kustomization = {
      source = "kbst/kustomization"
    }
  }

  required_version = ">= 0.15"
}
