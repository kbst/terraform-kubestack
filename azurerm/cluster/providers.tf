# https://github.com/terraform-providers/terraform-provider-external/releases
provider "external" {
  version = "~> 1.2.0"
}

# https://github.com/terraform-providers/terraform-provider-azurerm/releases
provider "azurerm" {
  version = "~> 2.23.0"

  features {}
}

# https://github.com/terraform-providers/terraform-provider-azuread/releases
provider "azuread" {
  version = "~> 0.11.0"
}

# https://github.com/terraform-providers/terraform-provider-kubernetes/releases
provider "kubernetes" {
  version = "~> 1.12.0"
}

# https://github.com/terraform-providers/terraform-provider-random/releases
provider "random" {
  version = "~> 2.3.0"
}

# https://github.com/terraform-providers/terraform-provider-template/releases
provider "template" {
  version = "~> 2.1.2"
}
