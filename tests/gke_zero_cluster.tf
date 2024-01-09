data "google_container_engine_versions" "gke_zero" {
  project        = "terraform-kubestack-testing"
  location       = "europe-west1"
  version_prefix = "1."
}

module "gke_zero" {
  providers = {
    kubernetes = kubernetes.gke_zero
  }

  source = "../google/cluster"

  configuration = {
    # Settings for Apps-cluster
    apps = {
      deletion_protection = false

      project_id  = "terraform-kubestack-testing"
      name_prefix = "kbstacctest"
      base_domain = "infra.serverwolken.de"

      cluster_min_master_version = data.google_container_engine_versions.gke_zero.default_cluster_version

      cluster_machine_type   = "e2-medium"
      cluster_min_node_count = 1
      cluster_max_node_count = 1

      region                 = "europe-west1"
      cluster_node_locations = "europe-west1-b,europe-west1-c,europe-west1-d"
    }

    # Settings for Ops-cluster
    ops = {}
  }
}
