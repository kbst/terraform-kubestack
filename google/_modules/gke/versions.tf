
terraform {
  required_providers {
    external = {
      # https://registry.terraform.io/providers/hashicorp/external/latest
      source  = "hashicorp/external"
      version = ">= 2.0.0"
    }

    google = {
      # https://registry.terraform.io/providers/hashicorp/google/latest
      source  = "hashicorp/google"
      version = ">= 3.55.0"
    }
  }

  required_version = ">= 0.13"
}
