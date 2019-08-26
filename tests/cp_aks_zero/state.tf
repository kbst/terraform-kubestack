terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-kubestack-testing"
    storage_account_name = "kubestacktesting"
    container_name       = "terraform-kubestack-testing-state"
    key                  = "tfstate"
  }
}
