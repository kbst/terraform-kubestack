variables {
  configuration = {
    apps_production = {
      apps_key1 = "from_apps_production"
      apps_key2 = "from_apps_production"
    }

    apps_staging = {
      apps_key1 = "from_apps_staging"
      apps_key2 = "from_apps_staging"
    }

    ops = {
      ops_key   = "from_ops"
      apps_key1 = "from_ops"
    }

    loc = {}
  }

  base_key = "apps_production"
}

run "custom_envs" {
  assert {
    condition     = output.merged["apps_production"] == { apps_key1 = "from_apps_production", apps_key2 = "from_apps_production" }
    error_message = "apps_production is unchanged"
  }

  assert {
    condition     = output.merged["apps_staging"] == { apps_key1 = "from_apps_staging", apps_key2 = "from_apps_staging" }
    error_message = "apps_staging overwrites everything from apps_production"
  }

  assert {
    condition     = output.merged["ops"] == { apps_key1 = "from_ops", apps_key2 = "from_apps_production", ops_key = "from_ops" }
    error_message = "ops inherits from apps_production, overwrites apps_key1 and adds ops_key"
  }

  assert {
    condition     = output.merged["loc"] == { apps_key1 = "from_apps_production", apps_key2 = "from_apps_production" }
    error_message = "loc inherits everything from apps_production"
  }
}
