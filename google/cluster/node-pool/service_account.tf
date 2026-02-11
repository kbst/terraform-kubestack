locals {
  account_id_prefix = join("-", [local.name, var.cluster_metadata["name"]])
  account_id_suffix = sha512(local.account_id_prefix)
  account_id        = "${substr(local.account_id_prefix, 0, 24)}-${substr(local.account_id_suffix, 0, 5)}"
}

resource "google_service_account" "current" {
  count = local.service_account_email == null ? 1 : 0

  account_id = local.account_id
  project    = local.project_id
}

resource "google_project_iam_member" "log_writer" {
  count = local.service_account_email == null ? 1 : 0

  project = local.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.current[0].email}"
}

resource "google_project_iam_member" "metric_writer" {
  count = local.service_account_email == null ? 1 : 0

  project = local.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.current[0].email}"
}
