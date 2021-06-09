data "tls_certificate" "current" {
  count = var.disable_openid_connect_provider == false ? 1 : 0

  url = aws_eks_cluster.current.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "current" {
  count = var.disable_openid_connect_provider == false ? 1 : 0

  client_id_list  = ["sts.${data.aws_partition.current.dns_suffix}"]
  thumbprint_list = [data.tls_certificate.current[0].certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.current.identity[0].oidc[0].issuer
}
