module "configuration" {
  source        = "github.com/kbst/terraform-kubestack//common/configuration?ref=v0.15.1-beta.1"
  configuration = var.configuration
  base_key      = var.configuration_base_key
}

locals {
  cfg = lookup(module.configuration.merged, terraform.workspace)
}
