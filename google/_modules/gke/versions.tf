
terraform {
  required_providers {
    external = {
      source  = "hashicorp/external"
      version = "~> 1.2.0"
    }

    google = {
      source  = "hashicorp/google"
      version = "~> 3.34.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 1.12.0"
    }
  }

  required_version = ">= 0.13"
}
