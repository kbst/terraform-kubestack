resource "scaleway_lb_ip" "current" {
  count = try(coalesce(local.cfg.disable_default_ingress, null), false) ? 0 : 1

  project_id = local.cfg.project_id

  tags = concat(module.cluster_metadata.tags, try(coalesce(local.cfg.extra_tags, null), []))
}

resource "scaleway_domain_zone" "current" {
  count = try(coalesce(local.cfg.disable_default_ingress, null), false) ? 0 : 1

  project_id = local.cfg.project_id

  domain    = local.cfg.base_domain
  subdomain = trimsuffix(module.cluster_metadata.fqdn, ".${local.cfg.base_domain}")
}

resource "scaleway_domain_record" "host" {
  count = try(coalesce(local.cfg.disable_default_ingress, null), false) ? 0 : 1

  dns_zone = scaleway_domain_zone.current[0].id
  name     = ""
  type     = "A"
  data     = scaleway_lb_ip.current[0].ip_address
  ttl      = 300
}

resource "scaleway_domain_record" "wildcard" {
  count = try(coalesce(local.cfg.disable_default_ingress, null), false) ? 0 : 1

  dns_zone = scaleway_domain_zone.current[0].id
  name     = "*"
  type     = "A"
  data     = scaleway_lb_ip.current[0].ip_address
  ttl      = 300
}
