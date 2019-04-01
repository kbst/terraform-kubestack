data "external" "aws_iam_authenticator" {
  program = ["sh", "${path.module}/provider_authenticator.sh"]

  query {
    cluster_name = "${aws_eks_cluster.current.name}"
  }
}

provider "kubernetes" {
  alias = "eks"

  load_config_file = false

  host                   = "${aws_eks_cluster.current.endpoint}"
  cluster_ca_certificate = "${base64decode(aws_eks_cluster.current.certificate_authority.0.data)}"

  token = "${data.external.aws_iam_authenticator.result["token"]}"
}
