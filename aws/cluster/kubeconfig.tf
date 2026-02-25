locals {
  kubeconfig = yamlencode({
    apiVersion = "v1"
    kind       = "Config"
    clusters = [
      {
        cluster = {
          server                     = aws_eks_cluster.current.endpoint
          certificate-authority-data = aws_eks_cluster.current.certificate_authority[0].data
        }
        name = aws_eks_cluster.current.name
      }
    ]
    users = [
      {
        user = {
          token = data.aws_eks_cluster_auth.current.token
        }
        name = aws_eks_cluster.current.name
      }
    ]
    contexts = [
      {
        context = {
          cluster = aws_eks_cluster.current.name
          user    = aws_eks_cluster.current.name
        }
        name = aws_eks_cluster.current.name
      }
    ]
    current-context = aws_eks_cluster.current.name
    preferences     = {}
  })
}
