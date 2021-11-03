terraform {
  required_providers {
    aws = {
      source = "hashicorp/google"
    }
  }

  required_version = ">= 0.15"
  experiments      = [module_variable_optional_attrs]
}
