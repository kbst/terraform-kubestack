resource "google_compute_address" "current" {
  count = local.disable_default_ingress ? 0 : 1

  region  = google_container_cluster.current.location
  project = local.project_id

  name = module.cluster_metadata.name
}

resource "google_dns_managed_zone" "current" {
  count = local.disable_default_ingress ? 0 : 1

  project = local.project_id

  name     = module.cluster_metadata.name
  dns_name = "${module.cluster_metadata.fqdn}."
}

resource "google_dns_record_set" "host" {
  count = local.disable_default_ingress ? 0 : 1

  project = local.project_id

  name = google_dns_managed_zone.current[0].dns_name
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.current[0].name

  rrdatas = [google_compute_address.current[0].address]
}

resource "google_dns_record_set" "wildcard" {
  count = local.disable_default_ingress ? 0 : 1

  project = local.project_id

  name = "*.${google_dns_managed_zone.current[0].dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.current[0].name

  rrdatas = [google_compute_address.current[0].address]
}
