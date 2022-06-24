resource "kubernetes_config_map" "current" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = <<MAPROLES
- rolearn: ${aws_iam_role.node.arn}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
${var.aws_auth_map_roles}
MAPROLES

    mapUsers = var.aws_auth_map_users

    mapAccounts = var.aws_auth_map_accounts
  }

  depends_on = [aws_eks_cluster.current]
}
