# https://github.com/terraform-providers/terraform-provider-external/releases
provider "external" {
  version = "~> 1.2.0"
}

# https://github.com/terraform-providers/terraform-provider-azurerm/releases
provider "azurerm" {
  version = "~> 2.11.0"

  features {}
}

# https://github.com/terraform-providers/terraform-provider-azuread/releases
provider "azuread" {
  version = "~> 0.9.0"
}

# https://github.com/terraform-providers/terraform-provider-kubernetes/releases
provider "kubernetes" {
  version = "~> 1.11.3"
}

# https://github.com/terraform-providers/terraform-provider-random/releases
provider "random" {
  version = "~> 2.2.1"
}

# https://github.com/terraform-providers/terraform-provider-template/releases
provider "template" {
  version = "~> 2.1.2"
}
