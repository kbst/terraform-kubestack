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

  dynamic "ipv4_subnet" {
    for_each = local.cfg.private_network_subnet != null ? [1] : []
    content {
      subnet = local.cfg.private_network_subnet
    }
  }
}

# When nodes have public IPs disabled (the default), a Public Gateway is
# required in each node zone so that private nodes can reach the internet
# through NAT (masquerade). One gateway per zone is created conditionally.
locals {
  # The set of zones that need a gateway: non-empty only when public IPs are
  # disabled on the default node pool.  Extra node pools share the same
  # private network and therefore benefit from the same gateways automatically.
  gateway_zones = try(coalesce(local.cfg.default_node_pool.public_ip_disabled, null), true) ? toset(coalesce(local.cfg.default_node_pool.zones, [])) : toset([])
}

resource "scaleway_vpc_public_gateway_ip" "current" {
  for_each = local.gateway_zones

  project_id = local.cfg.project_id
  zone       = each.value

  tags = concat(module.cluster_metadata.tags, try(coalesce(local.cfg.extra_tags, null), []))
}

resource "scaleway_vpc_public_gateway" "current" {
  for_each = local.gateway_zones

  name       = "${module.cluster_metadata.name}-${each.value}"
  project_id = local.cfg.project_id
  zone       = each.value

  type  = try(coalesce(local.cfg.public_gateway_type, null), "VPC-GW-S")
  ip_id = scaleway_vpc_public_gateway_ip.current[each.value].id

  tags = concat(module.cluster_metadata.tags, try(coalesce(local.cfg.extra_tags, null), []))
}

resource "scaleway_vpc_gateway_network" "current" {
  for_each = local.gateway_zones

  gateway_id         = scaleway_vpc_public_gateway.current[each.value].id
  private_network_id = scaleway_vpc_private_network.current.id
  zone               = each.value

  enable_masquerade = true

  ipam_config {
    push_default_route = true
  }
}
