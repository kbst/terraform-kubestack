variables {
  name_prefix     = "testn"
  base_domain     = "testd.example.com"
  provider_name   = "testp"
  provider_region = "testr"
  workspace       = "test_custom_label_namespace"
  label_namespace = "testlns-"
}

run "custom_label_namespace" {
  assert {
    condition = output.labels == {
      "testlns-cluster_name"            = "testn-test_custom_label_namespace-testr"
      "testlns-cluster_domain"          = "testp.testd.example.com"
      "testlns-cluster_fqdn"            = "testn-test_custom_label_namespace-testr.testp.testd.example.com"
      "testlns-cluster_workspace"       = "test_custom_label_namespace"
      "testlns-cluster_provider_name"   = "testp"
      "testlns-cluster_provider_region" = "testr"
    }
    error_message = "labels use the custom testlns- namespace as key prefix"
  }

  assert {
    condition     = output.label_namespace == "testlns-"
    error_message = "label_namespace returns the custom testlns- value"
  }
}
