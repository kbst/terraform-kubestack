locals {
  base_config = var.configuration[var.base_key]

  merged = {
    for env_key, env in var.configuration :
    env_key => {
      # loop through all config keys in base_key environment and current env
      # if current env has that key, use the value from current env
      # if not, use the value from the base_key environment
      for key in setunion(keys(env), keys(local.base_config)) :
      key => lookup(env, key, null) != null ? env[key] : local.base_config[key]
    }
  }
}

output "merged" {
  value = local.merged
}
