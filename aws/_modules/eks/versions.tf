
terraform {
  required_providers {
    aws = {
      # https://registry.terraform.io/providers/hashicorp/aws/latest
      source  = "hashicorp/aws"
      version = ">= 3.26.0"
    }

    kubernetes = {
      # https://registry.terraform.io/providers/hashicorp/kubernetes/latest
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.2"
    }

    tls = {
      # https://registry.terraform.io/providers/hashicorp/tls/latest
      source  = "hashicorp/tls"
      version = "3.4.0"
    }
  }

  required_version = ">= 0.13"
}
