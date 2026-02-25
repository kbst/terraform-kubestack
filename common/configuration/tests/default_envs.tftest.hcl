variables {
  configuration = {
    apps = {
      apps_key1 = "from_apps"
      apps_key2 = "from_apps"
    }

    ops = {
      ops_key   = "from_ops"
      apps_key1 = "from_ops"
    }

    loc = {
      loc_key = "from_loc"
    }
  }

  base_key = "apps"
}

run "default_envs" {
  assert {
    condition     = output.merged["apps"] == { apps_key1 = "from_apps", apps_key2 = "from_apps" }
    error_message = "apps is unchanged"
  }

  assert {
    condition     = output.merged["ops"] == { apps_key1 = "from_ops", apps_key2 = "from_apps", ops_key = "from_ops" }
    error_message = "ops inherits from apps, overwrites apps_key1 and adds ops_key"
  }

  assert {
    condition     = output.merged["loc"] == { apps_key1 = "from_apps", apps_key2 = "from_apps", loc_key = "from_loc" }
    error_message = "loc inherits from apps and adds loc_key"
  }
}
