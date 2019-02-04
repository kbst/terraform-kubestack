data "external" "gcloud_account" {
  program = ["sh", "${path.module}/gcloud_config_account.sh"]
}

resource "kubernetes_cluster_role_binding" "current" {
  provider = "kubernetes.gke"

  metadata {
    name = "cluster-admin-kubestack"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "User"
    name      = "${data.external.gcloud_account.result["user"]}"
    api_group = "rbac.authorization.k8s.io"
  }

  depends_on = ["google_container_cluster.current"]
}
