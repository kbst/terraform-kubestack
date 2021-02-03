resource "azuread_application" "current" {
  display_name = var.metadata_name
}

resource "azuread_service_principal" "current" {
  application_id = azuread_application.current.application_id
}

resource "random_string" "password" {
  length  = 64
  special = true
}

resource "azuread_service_principal_password" "current" {
  service_principal_id = azuread_service_principal.current.id
  value                = random_string.password.result
  end_date_relative    = var.service_principal_end_date_relative
}
