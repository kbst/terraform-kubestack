locals {
  base = {
    (var.base_key) = var.configuration[var.base_key]
  }

  overlays = {
    for name, _ in var.configuration :
    name => merge(var.configuration[var.base_key], var.configuration[name])
    if name != var.base_key
  }
}

output "merged" {
  value = merge(local.base, local.overlays)
}
