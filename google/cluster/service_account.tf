resource "google_service_account" "current" {
  account_id = substr(module.cluster_metadata.name, 0, 30)
  project    = local.project_id
}

resource "google_project_iam_member" "log_writer" {
  project = local.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.current.email}"
}

resource "google_project_iam_member" "metric_writer" {
  project = local.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.current.email}"
}
