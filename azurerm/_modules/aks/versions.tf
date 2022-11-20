
terraform {
  required_providers {
    azurerm = {
      # https://registry.terraform.io/providers/hashicorp/azurerm/latest
      source  = "hashicorp/azurerm"
      version = ">= 3.4.0"
    }

    azuread = {
      # https://registry.terraform.io/providers/hashicorp/azuread/latest
      source  = "hashicorp/azuread"
      version = ">= 1.3.0"
    }
  }

  required_version = ">= 0.13"
}
