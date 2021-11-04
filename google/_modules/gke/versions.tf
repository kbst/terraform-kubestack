
terraform {
  required_providers {
    google = {
      # https://registry.terraform.io/providers/hashicorp/google/latest
      source  = "hashicorp/google"
      version = ">= 4.0.0"
    }
  }

  required_version = ">= 0.13"
}
