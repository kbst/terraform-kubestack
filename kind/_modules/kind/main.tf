locals {
  kubeadm_config_patches = [
    <<INIT
kind: InitConfiguration
nodeRegistration:
  kubeletExtraArgs:
    node-labels: "ingress-ready=true"
    authorization-mode: "AlwaysAllow"
INIT
  ]

  extra_port_mappings = var.disable_default_ingress ? toset([]) : toset([
    {
      container_port = 80
      host_port      = var.http_port
      protocol       = "TCP"
    },
    {
      container_port = 443
      host_port      = var.https_port
      protocol       = "TCP"
    }
  ])
}

resource "kind_cluster" "current" {
  name       = lower(var.metadata_name)
  node_image = var.node_image

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"

      kubeadm_config_patches = var.disable_default_ingress ? null : local.kubeadm_config_patches

      dynamic "extra_port_mappings" {
        for_each = local.extra_port_mappings
        iterator = mapping

        content {
          container_port = mapping.value["container_port"]
          host_port      = mapping.value["host_port"]
          protocol       = mapping.value["protocol"]
        }
      }
    }

    dynamic "node" {
      for_each = split(",", var.extra_nodes)
      content {
        role = "worker"
      }
    }
  }
}
