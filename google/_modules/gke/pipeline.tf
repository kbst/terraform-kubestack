locals {
  k8s_sa_email = "${var.project}.svc.id.goog[${kubernetes_namespace.pipeline.metadata[0].name}/${kubernetes_service_account.pipeline.metadata[0].name}]"
}

resource "google_service_account" "pipeline" {
  account_id = "${var.metadata_name}-pl"
  project    = var.project
}

resource "google_project_iam_member" "container_admin" {
  project = var.project
  role    = "roles/container.admin"
  member  = "serviceAccount:${google_service_account.pipeline.email}"
}

resource "google_project_iam_member" "editor" {
  project = var.project
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.pipeline.email}"
}

resource "google_project_iam_member" "workload_identity_user" {
  project = var.project
  role    = "roles/iam.workloadIdentityUser"
  member  = "serviceAccount:${local.k8s_sa_email}"
}

resource "kubernetes_namespace" "pipeline" {
  provider = kubernetes.gke

  metadata {
    name = "kbst-pipeline"
  }

  # namespace metadata may change through the manifests
  # hence ignoring this for the terraform lifecycle
  lifecycle {
    ignore_changes = [metadata]
  }

  depends_on = [module.node_pool]
}

resource "kubernetes_service_account" "pipeline" {
  provider = kubernetes.gke

  metadata {
    name      = "kbst-pipeline"
    namespace = kubernetes_namespace.pipeline.metadata[0].name
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.pipeline.email
    }
  }

  secret {
    name = "ssh-auth"
  }
}
