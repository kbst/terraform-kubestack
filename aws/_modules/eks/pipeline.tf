resource "kubernetes_namespace" "pipeline" {
  provider = kubernetes.eks

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
  provider = kubernetes.eks

  metadata {
    name      = "kbst-pipeline"
    namespace = kubernetes_namespace.pipeline.metadata[0].name
  }

  secret {
    name = "ssh-auth"
  }
}
