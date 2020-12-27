
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.9.0"
    }

    external = {
      source  = "hashicorp/external"
      version = "~> 1.2.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 1.12.0"
    }
  }

  required_version = ">= 0.13"
}
