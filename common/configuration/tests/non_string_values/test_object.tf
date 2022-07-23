module "mut_object" {
  source = "./wrapper"
}

resource "test_assertions" "overwrite_object" {
  component = "overwrite_object"

  equal "scheme" {
    description = "can overwrite objects"
    got         = module.mut_object.merged
    want = {
      "apps" = {
        "test_list_object" = tolist([
          {
            "key" = "from_apps"
          },
        ])
        "test_list_string" = tolist([
          "from_apps",
        ])
        "test_map_string" = tomap({
          "key" = "from_apps"
        })
        "test_object" = {
          "key" = "from_apps"
        }
        "test_string" = "from_apps"
      }
      "loc" = {
        "test_list_object" = tolist([
          {
            "key" = "from_loc"
          },
        ])
        "test_list_string" = tolist([
          "from_apps",
        ])
        "test_map_string" = tomap({
          "key" = "from_apps"
        })
        "test_object" = {
          "key" = "from_apps"
        }
        "test_string" = "from_apps"
      }
      "ops" = {
        "test_list_object" = tolist([
          {
            "key" = "from_ops"
          },
        ])
        "test_list_string" = tolist([
          "from_ops",
        ])
        "test_map_string" = tomap({
          "key" = "from_ops"
        })
        "test_object" = {
          "key" = "from_ops"
        }
        "test_string" = "from_ops"
      }
    }
  }
}
