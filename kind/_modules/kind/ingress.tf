resource "kubernetes_namespace" "current" {
  provider = "kubernetes.kind"

  metadata {
    name = "ingress-kbst-default"
  }

  # namespace metadata may change through the manifests
  # hence ignoring this for the terraform lifecycle
  lifecycle {
    ignore_changes = ["metadata"]
  }

  depends_on = ["null_resource.cluster"]
}
