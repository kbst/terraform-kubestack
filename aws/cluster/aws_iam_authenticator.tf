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
${try(coalesce(local.cfg.cluster_aws_auth_map_roles, null), "")}
MAPROLES

    mapUsers = try(coalesce(local.cfg.cluster_aws_auth_map_users, null), "")

    mapAccounts = try(coalesce(local.cfg.cluster_aws_auth_map_accounts, null), "")
  }

  depends_on = [aws_eks_cluster.current]
}
