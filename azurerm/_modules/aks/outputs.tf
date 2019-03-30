output "ingress_zone_name_servers" {
  value       = "${azurerm_dns_zone.current.name_servers}"
  description = "Nameservers of the cluster's managed zone."
}
