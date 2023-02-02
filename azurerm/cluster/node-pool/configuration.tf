module "configuration" {
  source = "../../../common/configuration"

  configuration = var.configuration
  base_key      = var.configuration_base_key
}

locals {
  cfg = module.configuration.merged[terraform.workspace]
}
