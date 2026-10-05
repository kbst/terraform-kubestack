# Without a security group, pools use the shared "Kapsule default security
# group" of the Project per zone, which must not be modified as it is shared
# with all other pools. Instead, a dedicated security group with the SMTP
# block disabled is created per zone. It keeps the provider defaults, which
# replicate the Kapsule default behavior on the public interface: stateful
# with accept-all inbound and outbound policy. Security groups only filter
# public traffic, private network traffic is unaffected.
resource "scaleway_instance_security_group" "smtp" {
  for_each = local.smtp_enabled ? toset(coalesce(local.cfg.zones, [])) : toset([])

  name       = "${var.cluster_metadata.name}-${local.cfg.name}-${each.value}"
  project_id = var.cluster.project_id
  zone       = each.value

  enable_default_security = false

  tags = concat(var.cluster_metadata.tags, try(coalesce(local.cfg.tags, null), []))
}
