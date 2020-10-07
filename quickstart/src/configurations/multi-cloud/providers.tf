provider "aws" {
  alias = "eks_zero"

  # The AWS provider requires a region. Specify your region here,
  # the alias above is used to inject the correct provider into
  # the respective cluster module in clusters.tf
  region = ""
}
