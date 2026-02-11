# Moved blocks to maintain state compatibility after refactoring
# These blocks ensure that node pool resources are not recreated when upgrading
# from the old module structure to the new flattened structure.

moved {
  from = module.node_pool.google_container_node_pool.current
  to   = google_container_node_pool.current
}

moved {
  from = module.node_pool.google_service_account.current
  to   = google_service_account.current
}

moved {
  from = module.node_pool.google_project_iam_member.log_writer
  to   = google_project_iam_member.log_writer
}

moved {
  from = module.node_pool.google_project_iam_member.metric_writer
  to   = google_project_iam_member.metric_writer
}
