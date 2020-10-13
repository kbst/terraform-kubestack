
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.23.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 0.11.0"
    }

    external = {
      source  = "hashicorp/external"
      version = "~> 1.2.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 1.12.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 2.3.0"
    }
  }

  required_version = ">= 0.13"
}
