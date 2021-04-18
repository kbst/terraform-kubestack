terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }
  }
}

module "mut" {
  source = "../.."

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

resource "test_assertions" "apps" {
  component = "apps"

  equal "scheme" {
    description = "apps is unchanged"
    got         = module.mut.merged["apps"]
    want = {
      apps_key1 = "from_apps"
      apps_key2 = "from_apps"
    }
  }
}

resource "test_assertions" "ops" {
  component = "ops"

  equal "scheme" {
    description = "ops inherits from apps, overwrites apps_key1 and adds ops_key"
    got         = module.mut.merged["ops"]
    want = {
      apps_key1 = "from_ops"
      apps_key2 = "from_apps"
      ops_key   = "from_ops"
    }
  }
}

resource "test_assertions" "loc" {
  component = "loc"

  equal "scheme" {
    description = "loc inherits from apps and adds loc_key"
    got         = module.mut.merged["loc"]
    want = {
      apps_key1 = "from_apps"
      apps_key2 = "from_apps"
      loc_key   = "from_loc"
    }
  }
}
