
terraform {
  required_providers {
    google = {
      # https://registry.terraform.io/providers/hashicorp/google/latest
      source  = "hashicorp/google"
      version = ">= 4.76.0"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }

  required_version = ">= 0.13"
}
