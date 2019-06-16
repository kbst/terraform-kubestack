output "ingress_zone_name_servers" {
  value       = google_dns_managed_zone.current.name_servers
  description = "Nameservers of the cluster's managed zone."
}

