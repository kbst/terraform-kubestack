terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }

  required_version = ">= 0.15"
  experiments      = [module_variable_optional_attrs]
}
