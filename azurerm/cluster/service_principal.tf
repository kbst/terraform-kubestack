resource "azuread_application" "current" {
  count = try(coalesce(local.cfg.disable_managed_identities, null), false) == true ? 1 : 0

  display_name = module.cluster_metadata.name
}

resource "azuread_service_principal" "current" {
  count = try(coalesce(local.cfg.disable_managed_identities, null), false) == true ? 1 : 0

  client_id = azuread_application.current[0].client_id
}

resource "azuread_service_principal_password" "current" {
  count = try(coalesce(local.cfg.disable_managed_identities, null), false) == true ? 1 : 0

  service_principal_id = azuread_service_principal.current[0].id
}
