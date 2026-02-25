variables {
  name_prefix     = "testn"
  base_domain     = "testd.example.com"
  provider_name   = "testp"
  provider_region = "testr"
  workspace       = "testw"
}

run "custom_workspace" {
  assert {
    condition     = output.name == "testn-testw-testr"
    error_message = "name uses the explicitly provided workspace value instead of terraform.workspace"
  }

  assert {
    condition     = output.labels["kubestack.com/cluster_workspace"] == "testw"
    error_message = "cluster_workspace label reflects the custom workspace value"
  }

  assert {
    condition     = contains(output.tags, "testw")
    error_message = "tags contain the custom workspace value"
  }
}
