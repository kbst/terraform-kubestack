locals {
  base = {
    (var.base_key) = var.configuration[var.base_key]
  }

  overlays = {
    # include all envs but the base_key in overlays
    for env_key, env in var.configuration :
    env_key => {
      # loop through all config keys in base_key environment
      # if current env has that key, use the value from current env
      # if not, use the value from the base_key environment
      for key, value in var.configuration[var.base_key] :
      key => lookup(env, key, null) != null ? env[key] : value
    }
    if env_key != var.base_key
  }
}

output "merged" {
  value = merge(local.base, local.overlays)
}
