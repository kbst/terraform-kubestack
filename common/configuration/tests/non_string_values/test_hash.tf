module "mut_hash" {
  source = "../.."

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

    loc = {
    }
  }

  base_key = "apps"
}

resource "test_assertions" "merge_hash" {
  component = "merge_hash"

  equal "scheme" {
    description = "can merge hashes"
    got         = module.mut_hash.merged
    want = {
      "apps" = {
        "test_hash" = {
          "from_apps_1" = "from_apps_1"
          "from_apps_2" = "from_apps_2"
        }
      }
      "loc" = {
        "test_hash" = tomap({
          "from_apps_1" = "from_apps_1"
          "from_apps_2" = "from_apps_2"
        })
      }
      "ops" = {
        "test_hash" = {
          "from_apps_1" = "from_apps_1"
          "from_apps_2" = "from_apps_2"
          "from_ops_1"  = "from_ops_1"
        }
      }
    }
  }
}
