locals {
  base_cfg = var.configuration[var.base_key]

  merged = {
    # loop through all environments
    for env_key, env_cfg in var.configuration :
    env_key => {
      # loop through all keys in current and base_key environment config
      for cfg_key in setunion(keys(env_cfg), keys(local.base_cfg)) :
      cfg_key => try(
        # try one level of nesting
        {
          for nested_key in setunion(keys(env_cfg[cfg_key]), keys(local.base_cfg[cfg_key])) :
          nested_key => try(
            # use current environment's nested value or base env's value
            coalesce(
              lookup(env_cfg[cfg_key], nested_key, null),
              lookup(local.base_cfg[cfg_key], nested_key, null),
            ),
            local.base_cfg[cfg_key][nested_key]
          )
        },
        # fall back to use current environment's value or base env's value
        coalesce(
          lookup(env_cfg, cfg_key, null),
          lookup(local.base_cfg, cfg_key, null),
        ),
        local.base_cfg[cfg_key]
      )
    }
  }
}

output "merged" {
  value = local.merged
}
