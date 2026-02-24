module "mut_object" {
  source = "./wrapper"
}

resource "test_assertions" "merge_object" {
  component = "merge_object"

  equal "scheme" {
    description = "can merge objects"
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
        "test_map_object" = {
          "env" = {
            "key" = "from_apps"
          }
        }
        "test_map_string" = {
          "key" = "from_apps"
        }
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
        "test_map_object" = tomap({
          "env" = {
            "key" = "from_apps"
          }
        })
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
        "test_map_object" = {
          "env" = {
            "key" = "from_ops"
          }
        }
        "test_map_string" = {
          "key" = "from_ops"
        }
        "test_object" = {
          "key" = "from_ops"
        }
        "test_string" = "from_ops"
      }
    }
  }
}
