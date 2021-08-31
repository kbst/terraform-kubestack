resource "google_compute_address" "current" {
  count = var.disable_default_ingress ? 0 : 1

  region  = google_container_cluster.current.location
  project = var.project

  name = var.metadata_name

  # depend on node pool, to ensure
  # ingress controller namespace
  # is destroyed before node pool
  depends_on = [module.node_pool]
}

resource "google_dns_managed_zone" "current" {
  count = var.disable_default_ingress ? 0 : 1

  project = var.project

  name     = var.metadata_name
  dns_name = "${var.metadata_fqdn}."
}

resource "google_dns_record_set" "host" {
  count = var.disable_default_ingress ? 0 : 1

  project = var.project

  name = google_dns_managed_zone.current[0].dns_name
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.current[0].name

  rrdatas = [google_compute_address.current[0].address]
}

resource "google_dns_record_set" "wildcard" {
  count = var.disable_default_ingress ? 0 : 1

  project = var.project

  name = "*.${google_dns_managed_zone.current[0].dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.current[0].name

  rrdatas = [google_compute_address.current[0].address]
}
