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

resource "test_assertions" "apps_production" {
  component = "apps_production"

  equal "scheme" {
    description = "apps_production is unchanged"
    got         = module.mut.merged["apps_production"]
    want = {
      apps_key1 = "from_apps_production"
      apps_key2 = "from_apps_production"
    }
  }
}

resource "test_assertions" "apps_staging" {
  component = "apps_staging"

  equal "scheme" {
    description = "apps_staging overwrites everything from apps_production"
    got         = module.mut.merged["apps_staging"]
    want = {
      apps_key1 = "from_apps_staging"
      apps_key2 = "from_apps_staging"
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
      apps_key2 = "from_apps_production"
      ops_key   = "from_ops"
    }
  }
}

resource "test_assertions" "loc" {
  component = "loc"

  equal "scheme" {
    description = "loc inherits from apps, nulls apps_key2, and adds loc_key"
    got         = module.mut.merged["loc"]
    want = {
      apps_key1 = "from_apps_production"
      apps_key2 = "from_apps_production"
    }
  }
}
