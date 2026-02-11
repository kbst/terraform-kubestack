# Moved blocks to maintain state compatibility after refactoring
# These blocks ensure that resources are not recreated when upgrading
# from the old module structure to the new flattened structure.

moved {
  from = module.cluster.google_container_cluster.current
  to   = google_container_cluster.current
}

moved {
  from = module.cluster.data.google_client_openid_userinfo.current
  to   = data.google_client_openid_userinfo.current
}

moved {
  from = module.cluster.kubernetes_cluster_role_binding.current
  to   = kubernetes_cluster_role_binding.current
}

moved {
  from = module.cluster.google_compute_address.current
  to   = google_compute_address.current
}

moved {
  from = module.cluster.google_dns_managed_zone.current
  to   = google_dns_managed_zone.current
}

moved {
  from = module.cluster.google_dns_record_set.host
  to   = google_dns_record_set.host
}

moved {
  from = module.cluster.google_dns_record_set.wildcard
  to   = google_dns_record_set.wildcard
}

moved {
  from = module.cluster.google_compute_network.current
  to   = google_compute_network.current
}

moved {
  from = module.cluster.google_compute_address.nat
  to   = google_compute_address.nat
}

moved {
  from = module.cluster.google_compute_router.current
  to   = google_compute_router.current
}

moved {
  from = module.cluster.google_compute_router_nat.nat
  to   = google_compute_router_nat.nat
}

moved {
  from = module.cluster.module.node_pool
  to   = module.node_pool
}

# Moved block for the default node pool resource to module migration
# The refactoring initially moved the default node pool from module.node_pool to a direct resource
# Now we're moving it back to use the module pattern for consistency
moved {
  from = google_container_node_pool.default
  to   = module.node_pool.google_container_node_pool.current
}

moved {
  from = module.cluster.data.google_client_config.default
  to   = data.google_client_config.default
}

moved {
  from = module.cluster.google_service_account.current
  to   = google_service_account.current
}

moved {
  from = module.cluster.google_project_iam_member.log_writer
  to   = google_project_iam_member.log_writer
}

moved {
  from = module.cluster.google_project_iam_member.metric_writer
  to   = google_project_iam_member.metric_writer
}
