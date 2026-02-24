terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
    }

    tls = {
      source = "hashicorp/tls"
    }
  }

  required_version = ">= 0.13"
}
