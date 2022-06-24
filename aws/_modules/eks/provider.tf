data "aws_partition" "current" {}

data "aws_eks_cluster_auth" "current" {
  name = aws_eks_cluster.current.name
}

provider "kubernetes" {
  alias = "eks"

  host                   = aws_eks_cluster.current.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.current.certificate_authority[0].data)

  token = data.aws_eks_cluster_auth.current.token
}
