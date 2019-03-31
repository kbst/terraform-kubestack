terraform {
  backend "gcs" {
    bucket = "terraform-kubestack-testing-state"
  }
}
