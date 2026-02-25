variables {
  name_prefix     = "testn"
  base_domain     = "testd.example.com"
  provider_name   = "testp"
  provider_region = "testr"
  # Set workspace explicitly so the test is self-contained and does not depend
  # on whichever Terraform/OpenTofu workspace happens to be selected at runtime.
  workspace = "test_defaults"
}

run "defaults" {
  assert {
    condition     = output.name == "testn-test_defaults-testr"
    error_message = "name concatenates name_prefix, workspace and provider_region with default delimiter"
  }

  assert {
    condition     = output.domain == "testp.testd.example.com"
    error_message = "domain concatenates provider_name and base_domain"
  }

  assert {
    condition     = output.fqdn == "testn-test_defaults-testr.testp.testd.example.com"
    error_message = "fqdn concatenates name and domain"
  }

  assert {
    condition = output.labels == {
      "kubestack.com/cluster_name"            = "testn-test_defaults-testr"
      "kubestack.com/cluster_domain"          = "testp.testd.example.com"
      "kubestack.com/cluster_fqdn"            = "testn-test_defaults-testr.testp.testd.example.com"
      "kubestack.com/cluster_workspace"       = "test_defaults"
      "kubestack.com/cluster_provider_name"   = "testp"
      "kubestack.com/cluster_provider_region" = "testr"
    }
    error_message = "labels have correct key/value pairs using the default kubestack.com/ namespace"
  }

  assert {
    condition     = output.label_namespace == "kubestack.com/"
    error_message = "label_namespace returns the default kubestack.com/ value"
  }

  assert {
    condition     = output.tags == ["testn-test_defaults-testr", "test_defaults", "testp", "testr"]
    error_message = "tags contain name, workspace, provider_name and provider_region in order"
  }
}
