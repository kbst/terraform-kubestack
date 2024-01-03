resource "azuread_application" "current" {
  count = var.disable_managed_identities == true ? 1 : 0

  display_name = var.metadata_name
}

resource "azuread_service_principal" "current" {
  count = var.disable_managed_identities == true ? 1 : 0

  client_id = azuread_application.current[0].client_id
}

resource "azuread_service_principal_password" "current" {
  count = var.disable_managed_identities == true ? 1 : 0

  service_principal_id = azuread_service_principal.current[0].id
}
