
terraform {
  required_providers {
    azurerm = {
      # https://registry.terraform.io/providers/hashicorp/azurerm/latest
      source  = "hashicorp/azurerm"
      version = ">= 2.45.1"
    }

    azuread = {
      # https://registry.terraform.io/providers/hashicorp/azuread/latest
      source  = "hashicorp/azuread"
      version = ">= 1.3.0"
    }

    external = {
      # https://registry.terraform.io/providers/hashicorp/external/latest
      source  = "hashicorp/external"
      version = ">= 2.0.0"
    }

    kubernetes = {
      # https://registry.terraform.io/providers/hashicorp/kubernetes/latest
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.2"
    }

    random = {
      # https://registry.terraform.io/providers/hashicorp/random/latest
      source  = "hashicorp/random"
      version = ">= 3.0.1"
    }
  }

  required_version = ">= 0.13"
}
