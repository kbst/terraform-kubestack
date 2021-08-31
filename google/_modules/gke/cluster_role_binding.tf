data "google_client_openid_userinfo" "current" {
}

resource "kubernetes_cluster_role_binding" "current" {
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
    name      = data.google_client_openid_userinfo.current.email
    api_group = "rbac.authorization.k8s.io"
  }

  depends_on = [google_container_cluster.current]
}
