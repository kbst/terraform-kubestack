terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 5.0.0"
    }

    azuread = {
      source = "hashicorp/azuread"
    }
  }

  required_version = ">= 0.13"
}
