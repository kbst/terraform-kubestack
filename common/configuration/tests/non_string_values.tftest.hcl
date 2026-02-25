run "merge_lists" {
  variables {
    configuration = {
      apps = {
        test_list = ["from_apps_1", "from_apps_2"]
      }

      ops = {
        test_list = ["from_ops_1"]
      }

      loc = {}
    }

    base_key = "apps"
  }

  assert {
    condition     = output.merged["apps"]["test_list"][0] == "from_apps_1"
    error_message = "apps list first element is from_apps_1"
  }

  assert {
    condition     = output.merged["apps"]["test_list"][1] == "from_apps_2"
    error_message = "apps list second element is from_apps_2"
  }

  assert {
    condition     = length(output.merged["apps"]["test_list"]) == 2
    error_message = "apps list has exactly 2 elements"
  }

  assert {
    condition     = output.merged["ops"]["test_list"][0] == "from_ops_1"
    error_message = "ops list is overwritten and first element is from_ops_1"
  }

  assert {
    condition     = length(output.merged["ops"]["test_list"]) == 1
    error_message = "ops list is overwritten and has exactly 1 element"
  }

  assert {
    condition     = output.merged["loc"]["test_list"][0] == "from_apps_1"
    error_message = "loc list inherits from apps and first element is from_apps_1"
  }

  assert {
    condition     = output.merged["loc"]["test_list"][1] == "from_apps_2"
    error_message = "loc list inherits from apps and second element is from_apps_2"
  }

  assert {
    condition     = length(output.merged["loc"]["test_list"]) == 2
    error_message = "loc list inherits from apps and has exactly 2 elements"
  }
}

run "merge_hashes" {
  variables {
    configuration = {
      apps = {
        test_hash = {
          "from_apps_1" = "from_apps_1"
          "from_apps_2" = "from_apps_2"
        }
      }

      ops = {
        test_hash = {
          "from_ops_1" = "from_ops_1"
        }
      }

      loc = {}
    }

    base_key = "apps"
  }

  assert {
    condition     = output.merged["apps"]["test_hash"]["from_apps_1"] == "from_apps_1"
    error_message = "apps hash has from_apps_1 key"
  }

  assert {
    condition     = output.merged["apps"]["test_hash"]["from_apps_2"] == "from_apps_2"
    error_message = "apps hash has from_apps_2 key"
  }

  assert {
    condition     = output.merged["ops"]["test_hash"]["from_apps_1"] == "from_apps_1"
    error_message = "ops hash inherits from_apps_1 from apps"
  }

  assert {
    condition     = output.merged["ops"]["test_hash"]["from_apps_2"] == "from_apps_2"
    error_message = "ops hash inherits from_apps_2 from apps"
  }

  assert {
    condition     = output.merged["ops"]["test_hash"]["from_ops_1"] == "from_ops_1"
    error_message = "ops hash merges in from_ops_1 key"
  }

  assert {
    condition     = output.merged["loc"]["test_hash"]["from_apps_1"] == "from_apps_1"
    error_message = "loc hash inherits from_apps_1 from apps"
  }

  assert {
    condition     = output.merged["loc"]["test_hash"]["from_apps_2"] == "from_apps_2"
    error_message = "loc hash inherits from_apps_2 from apps"
  }
}

run "merge_objects" {
  variables {
    configuration = {
      apps = {
        test_string      = "from_apps"
        test_list_string = ["from_apps"]
        test_map_string  = { key = "from_apps" }
        test_list_object = [{ key = "from_apps" }]
        test_object      = { key = "from_apps" }
        test_map_object  = { env = { key = "from_apps" } }
      }

      ops = {
        test_string      = "from_ops"
        test_list_string = ["from_ops"]
        test_map_string  = { key = "from_ops" }
        test_list_object = [{ key = "from_ops" }]
        test_object      = { key = "from_ops" }
        test_map_object  = { env = { key = "from_ops" } }
      }

      loc = {
        test_string      = "from_apps"
        test_list_string = ["from_apps"]
        test_map_string  = { key = "from_apps" }
        test_list_object = [{ key = "from_loc" }]
        test_object      = { key = "from_apps" }
        test_map_object  = { env = { key = "from_apps" } }
      }
    }

    base_key = "apps"
  }

  # apps is the base and is unchanged
  assert {
    condition     = output.merged["apps"]["test_string"] == "from_apps"
    error_message = "apps test_string is from_apps"
  }

  assert {
    condition     = output.merged["apps"]["test_list_string"][0] == "from_apps"
    error_message = "apps test_list_string first element is from_apps"
  }

  assert {
    condition     = output.merged["apps"]["test_map_string"]["key"] == "from_apps"
    error_message = "apps test_map_string key is from_apps"
  }

  assert {
    condition     = output.merged["apps"]["test_list_object"][0]["key"] == "from_apps"
    error_message = "apps test_list_object first element key is from_apps"
  }

  assert {
    condition     = output.merged["apps"]["test_object"]["key"] == "from_apps"
    error_message = "apps test_object key is from_apps"
  }

  assert {
    condition     = output.merged["apps"]["test_map_object"]["env"]["key"] == "from_apps"
    error_message = "apps test_map_object env key is from_apps"
  }

  # ops completely overrides all values from apps
  assert {
    condition     = output.merged["ops"]["test_string"] == "from_ops"
    error_message = "ops test_string overrides apps and is from_ops"
  }

  assert {
    condition     = output.merged["ops"]["test_list_string"][0] == "from_ops"
    error_message = "ops test_list_string overrides apps and first element is from_ops"
  }

  assert {
    condition     = output.merged["ops"]["test_map_string"]["key"] == "from_ops"
    error_message = "ops test_map_string overrides apps and key is from_ops"
  }

  assert {
    condition     = output.merged["ops"]["test_list_object"][0]["key"] == "from_ops"
    error_message = "ops test_list_object overrides apps and first element key is from_ops"
  }

  assert {
    condition     = output.merged["ops"]["test_object"]["key"] == "from_ops"
    error_message = "ops test_object overrides apps and key is from_ops"
  }

  assert {
    condition     = output.merged["ops"]["test_map_object"]["env"]["key"] == "from_ops"
    error_message = "ops test_map_object overrides apps and env key is from_ops"
  }

  # loc only overrides test_list_object, inheriting everything else from apps
  assert {
    condition     = output.merged["loc"]["test_string"] == "from_apps"
    error_message = "loc test_string is inherited from apps"
  }

  assert {
    condition     = output.merged["loc"]["test_list_string"][0] == "from_apps"
    error_message = "loc test_list_string is inherited from apps"
  }

  assert {
    condition     = output.merged["loc"]["test_map_string"]["key"] == "from_apps"
    error_message = "loc test_map_string is inherited from apps"
  }

  assert {
    condition     = output.merged["loc"]["test_list_object"][0]["key"] == "from_loc"
    error_message = "loc test_list_object is overridden and first element key is from_loc"
  }

  assert {
    condition     = output.merged["loc"]["test_object"]["key"] == "from_apps"
    error_message = "loc test_object is inherited from apps"
  }

  assert {
    condition     = output.merged["loc"]["test_map_object"]["env"]["key"] == "from_apps"
    error_message = "loc test_map_object is inherited from apps"
  }
}
