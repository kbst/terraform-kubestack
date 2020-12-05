resource "google_container_registry" "registry" {
  count = var.disable_container_registry ? 0 : 1

  project  = var.project
  location = var.location
}

resource "google_storage_bucket_iam_member" "viewer" {
  bucket = google_container_registry.registry.id
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.current.email}"
}
