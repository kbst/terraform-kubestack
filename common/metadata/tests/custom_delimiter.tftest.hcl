variables {
  name_prefix     = "testn"
  base_domain     = "testd.example.com"
  provider_name   = "testp"
  provider_region = "testr"
  workspace       = "test_custom_delimiter"
  delimiter       = ""
}

run "custom_delimiter" {
  assert {
    condition     = output.name == "testntest_custom_delimitertestr"
    error_message = "name concatenates name_prefix, workspace and provider_region with empty delimiter"
  }

  assert {
    condition     = output.domain == "testp.testd.example.com"
    error_message = "domain is unaffected by the name delimiter and uses dot separation"
  }

  assert {
    condition     = output.fqdn == "testntest_custom_delimitertestr.testp.testd.example.com"
    error_message = "fqdn concatenates name (with empty delimiter) and domain"
  }

  assert {
    condition = output.labels == {
      "kubestack.com/cluster_name"            = "testntest_custom_delimitertestr"
      "kubestack.com/cluster_domain"          = "testp.testd.example.com"
      "kubestack.com/cluster_fqdn"            = "testntest_custom_delimitertestr.testp.testd.example.com"
      "kubestack.com/cluster_workspace"       = "test_custom_delimiter"
      "kubestack.com/cluster_provider_name"   = "testp"
      "kubestack.com/cluster_provider_region" = "testr"
    }
    error_message = "labels reflect the name built with the empty delimiter"
  }

  assert {
    condition     = output.label_namespace == "kubestack.com/"
    error_message = "label_namespace is unaffected by the delimiter and returns kubestack.com/"
  }

  assert {
    condition     = output.tags == ["testntest_custom_delimitertestr", "test_custom_delimiter", "testp", "testr"]
    error_message = "tags contain name (with empty delimiter), workspace, provider_name and provider_region in order"
  }
}
