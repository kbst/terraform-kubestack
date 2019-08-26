terraform {
  backend "s3" {
    bucket = "terraform-kubestack-testing-state"
    region = "eu-west-1"
    key    = "tfstate"
  }
}
