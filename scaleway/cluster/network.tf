resource "scaleway_vpc" "current" {
  name       = module.cluster_metadata.name
  project_id = local.cfg.project_id
  region     = local.cfg.region
  tags       = concat(module.cluster_metadata.tags, try(coalesce(local.cfg.extra_tags, null), []))

  enable_routing = try(coalesce(local.cfg.vpc_enable_routing, null), true)
}

resource "scaleway_vpc_private_network" "current" {
  name       = module.cluster_metadata.name
  project_id = local.cfg.project_id
  region     = local.cfg.region
  tags       = concat(module.cluster_metadata.tags, try(coalesce(local.cfg.extra_tags, null), []))

  vpc_id = scaleway_vpc.current.id

  ipv4_subnet {
    subnet = try(coalesce(local.cfg.private_network_subnet, null), "10.0.0.0/8")
  }
}
