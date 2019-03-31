provider "aws" {
  alias  = "eks_zero"
  region = "eu-west-1"
}

provider "google" {}

provider "google-beta" {}

provider "azurerm" {}
