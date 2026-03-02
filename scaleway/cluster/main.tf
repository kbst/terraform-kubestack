module "configuration" {
  source        = "../../common/configuration"
  configuration = var.configuration
  base_key      = var.configuration_base_key
}

locals {
  cfg = module.configuration.merged[terraform.workspace]
}

module "cluster_metadata" {
  source = "../../common/metadata"

  name_prefix = local.cfg.name_prefix
  base_domain = local.cfg.base_domain

  provider_name   = "scw"
  provider_region = local.cfg.region
}

resource "scaleway_k8s_cluster" "current" {
  name       = module.cluster_metadata.name
  project_id = local.cfg.project_id
  region     = local.cfg.region

  lifecycle {
    precondition {
      condition     = local.cfg.region != null
      error_message = "missing required configuration attribute: region"
    }

    precondition {
      condition     = local.cfg.cluster_version != null
      error_message = "missing required configuration attribute: cluster_version"
    }
  }
  tags = concat(module.cluster_metadata.tags, try(coalesce(local.cfg.extra_tags, null), []))

  type    = "kapsule"
  version = local.cfg.cluster_version
  cni     = try(coalesce(local.cfg.cni, null), "cilium")

  description = local.cfg.description

  private_network_id = scaleway_vpc_private_network.current.id

  delete_additional_resources = try(coalesce(local.cfg.delete_additional_resources, null), false)

  pod_cidr     = local.cfg.pod_cidr
  service_cidr = local.cfg.service_cidr

  feature_gates     = try(coalesce(local.cfg.feature_gates, null), [])
  admission_plugins = try(coalesce(local.cfg.admission_plugins, null), [])

  dynamic "autoscaler_config" {
    for_each = local.cfg.autoscaler_config != null ? [1] : []

    content {
      disable_scale_down               = try(coalesce(local.cfg.autoscaler_config.disable_scale_down, null), false)
      scale_down_delay_after_add       = local.cfg.autoscaler_config.scale_down_delay_after_add
      scale_down_unneeded_time         = local.cfg.autoscaler_config.scale_down_unneeded_time
      estimator                        = try(coalesce(local.cfg.autoscaler_config.estimator, null), "binpacking")
      expander                         = try(coalesce(local.cfg.autoscaler_config.expander, null), "random")
      ignore_daemonsets_utilization    = try(coalesce(local.cfg.autoscaler_config.ignore_daemonsets_utilization, null), false)
      balance_similar_node_groups      = try(coalesce(local.cfg.autoscaler_config.balance_similar_node_groups, null), false)
      expendable_pods_priority_cutoff  = local.cfg.autoscaler_config.expendable_pods_priority_cutoff
      scale_down_utilization_threshold = local.cfg.autoscaler_config.scale_down_utilization_threshold
      max_graceful_termination_sec     = local.cfg.autoscaler_config.max_graceful_termination_sec
    }
  }

  auto_upgrade {
    enable                        = try(coalesce(local.cfg.auto_upgrade.enable, null), true)
    maintenance_window_start_hour = try(coalesce(local.cfg.auto_upgrade.maintenance_window_start_hour, null), 3)
    maintenance_window_day        = try(coalesce(local.cfg.auto_upgrade.maintenance_window_day, null), "any")
  }
}
