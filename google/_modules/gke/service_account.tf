resource "google_service_account" "current" {
  account_id = substr(var.metadata_name, 0, 30)
  project    = var.project
}

resource "google_project_iam_member" "log_writer" {
  project = var.project
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.current.email}"
}

resource "google_project_iam_member" "metric_writer" {
  project = var.project
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.current.email}"
}

