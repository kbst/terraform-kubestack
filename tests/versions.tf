terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }

    kustomization = {
      source = "kbst/kustomization"
    }

    aws = {
      source = "hashicorp/aws"
    }

    azurerm = {
      source = "hashicorp/azurerm"
    }

    google = {
      source = "hashicorp/google"
    }

    scaleway = {
      source = "scaleway/scaleway"
    }
  }
}
