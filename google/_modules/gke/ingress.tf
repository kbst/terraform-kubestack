resource "google_compute_address" "current" {
  region  = google_container_cluster.current.location
  project = var.project

  name = var.metadata_name
}

resource "kubernetes_service" "current" {
  provider = kubernetes.gke

  metadata {
    name      = "ingress-kbst-default"
    namespace = "ingress-kbst-default"
  }

  spec {
    type             = "LoadBalancer"
    load_balancer_ip = google_compute_address.current.address

    selector = {
      "kubestack.com/ingress-default" = "true"
    }

    port {
      name        = "http"
      port        = 80
      target_port = "http"
    }

    port {
      name        = "https"
      port        = 443
      target_port = "https"
    }
  }

  # the cluster_services module creates the ingress-kbst-default namespace
  depends_on = [module.cluster_services]
}

resource "google_dns_managed_zone" "current" {
  project = var.project

  name     = var.metadata_name
  dns_name = "${var.metadata_fqdn}."
}

resource "google_dns_record_set" "host" {
  project = var.project

  name = google_dns_managed_zone.current.dns_name
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.current.name

  rrdatas = [google_compute_address.current.address]
}

resource "google_dns_record_set" "wildcard" {
  project = var.project

  name = "*.${google_dns_managed_zone.current.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.current.name

  rrdatas = [google_compute_address.current.address]
}
