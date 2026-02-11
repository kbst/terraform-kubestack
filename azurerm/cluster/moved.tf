# Moved blocks to maintain state compatibility after refactoring
# These blocks ensure that resources are not recreated when upgrading
# from the old module structure to the new flattened structure.

moved {
  from = module.cluster.azurerm_public_ip.current
  to   = azurerm_public_ip.current
}

moved {
  from = module.cluster.azurerm_dns_zone.current
  to   = azurerm_dns_zone.current
}

moved {
  from = module.cluster.azurerm_dns_a_record.host
  to   = azurerm_dns_a_record.host
}

moved {
  from = module.cluster.azurerm_dns_a_record.wildcard
  to   = azurerm_dns_a_record.wildcard
}

moved {
  from = module.cluster.azurerm_log_analytics_workspace.current
  to   = azurerm_log_analytics_workspace.current
}

moved {
  from = module.cluster.azurerm_log_analytics_solution.current
  to   = azurerm_log_analytics_solution.current
}

moved {
  from = module.cluster.data.azurerm_resource_group.current
  to   = data.azurerm_resource_group.current
}

moved {
  from = module.cluster.azurerm_kubernetes_cluster.current
  to   = azurerm_kubernetes_cluster.current
}

moved {
  from = module.cluster.azuread_application.current
  to   = azuread_application.current
}

moved {
  from = module.cluster.azuread_service_principal.current
  to   = azuread_service_principal.current
}

moved {
  from = module.cluster.azuread_service_principal_password.current
  to   = azuread_service_principal_password.current
}

moved {
  from = module.cluster.azurerm_virtual_network.current
  to   = azurerm_virtual_network.current
}

moved {
  from = module.cluster.azurerm_subnet.current
  to   = azurerm_subnet.current
}
