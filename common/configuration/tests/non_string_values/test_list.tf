module "mut_list" {
  source = "../.."

  configuration = {
    apps = {
      test_list = [
        "from_apps_1",
        "from_apps_2"
      ]
    }

    ops = {
      test_list = [
        "from_ops_1"
      ]
    }

    loc = {
    }
  }

  base_key = "apps"
}

resource "test_assertions" "overwrite_list" {
  component = "overwrite_list"

  equal "scheme" {
    description = "can overwrite lists"
    got         = module.mut_list.merged
    want = {
      "apps" = {
        "test_list" = tolist([
          "from_apps_1",
          "from_apps_2",
        ])
      }
      "loc" = {
        "test_list" = tolist([
          "from_apps_1",
          "from_apps_2",
        ])
      }
      "ops" = {
        "test_list" = tolist([
          "from_ops_1",
        ])
      }
    }
  }
}
