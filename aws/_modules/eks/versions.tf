
terraform {
  required_providers {
    aws = {
      # https://registry.terraform.io/providers/hashicorp/aws/latest
      source  = "hashicorp/aws"
      version = "~> 3.26.0"
    }

    external = {
      # https://registry.terraform.io/providers/hashicorp/external/latest
      source  = "hashicorp/external"
      version = "~> 2.0.0"
    }

    kubernetes = {
      # https://registry.terraform.io/providers/hashicorp/kubernetes/latest
      source  = "hashicorp/kubernetes"
      version = "~> 2.0.2"
    }
  }

  required_version = ">= 0.13"
}
