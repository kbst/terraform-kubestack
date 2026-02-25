terraform {
  required_providers {
    scaleway = {
      source = "scaleway/scaleway"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
  required_version = ">= 1.3.0"
}
