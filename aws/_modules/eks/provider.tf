data "aws_caller_identity" "current" {
}

data "aws_arn" "current" {
  arn = data.aws_caller_identity.current.arn
}

locals {
  resource_split     = split("/", data.aws_arn.current.resource)
  caller_id_arn_type = replace(element(local.resource_split, 0), "assumed-role", "role")
  caller_id_name     = element(local.resource_split, 1)

  caller_id_arn = "arn:aws:iam::${data.aws_arn.current.account}:${local.caller_id_arn_type}/${local.caller_id_name}"
}

data "external" "aws_iam_authenticator" {
  program = ["sh", "${path.module}/provider_authenticator.sh"]

  query = {
    cluster_name       = aws_eks_cluster.current.name
    caller_id_arn      = local.caller_id_arn
    caller_id_arn_type = local.caller_id_arn_type
  }
}

data "aws_eks_cluster_auth" "current" {
  name = aws_eks_cluster.current.name
}

provider "kubernetes" {
  alias = "eks"

  load_config_file = false

  host                    = aws_eks_cluster.current.endpoint
  cluster_ca_certificate  = base64decode(aws_eks_cluster.current.certificate_authority[0].data)

  token                   = data.aws_eks_cluster_auth.current.token
}

