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
${local.cluster_aws_auth_map_roles}
MAPROLES

    mapUsers = local.cluster_aws_auth_map_users

    mapAccounts = local.cluster_aws_auth_map_accounts
  }

  depends_on = [aws_eks_cluster.current]
}
