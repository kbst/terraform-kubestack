terraform {
  required_providers {
    azure = {
      source = "hashicorp/azurerm"
    }
  }

  required_version = ">= 0.15"
  experiments      = [module_variable_optional_attrs]
}
