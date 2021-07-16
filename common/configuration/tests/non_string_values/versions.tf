terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }
  }

  experiments = [module_variable_optional_attrs]
}
