moved {
  from = module.cluster.aws_eks_cluster.current
  to   = aws_eks_cluster.current
}

moved {
  from = module.cluster.aws_vpc.current
  to   = aws_vpc.current
}

moved {
  from = module.cluster.aws_subnet.current
  to   = aws_subnet.current
}

moved {
  from = module.cluster.aws_subnet.node_pool
  to   = aws_subnet.node_pool
}

moved {
  from = module.cluster.aws_internet_gateway.current
  to   = aws_internet_gateway.current
}

moved {
  from = module.cluster.aws_eip.nat_gw
  to   = aws_eip.nat_gw
}

moved {
  from = module.cluster.aws_nat_gateway.current
  to   = aws_nat_gateway.current
}

moved {
  from = module.cluster.aws_route_table.current
  to   = aws_route_table.current
}

moved {
  from = module.cluster.aws_route.current
  to   = aws_route.current
}

moved {
  from = module.cluster.aws_route_table_association.current
  to   = aws_route_table_association.current
}

moved {
  from = module.cluster.aws_route_table.node_pool
  to   = aws_route_table.node_pool
}

moved {
  from = module.cluster.aws_route.node_pool
  to   = aws_route.node_pool
}

moved {
  from = module.cluster.aws_route_table_association.node_pool
  to   = aws_route_table_association.node_pool
}

moved {
  from = module.cluster.aws_iam_role.master
  to   = aws_iam_role.master
}

moved {
  from = module.cluster.aws_iam_role_policy_attachment.master_cluster_policy
  to   = aws_iam_role_policy_attachment.master_cluster_policy
}

moved {
  from = module.cluster.aws_iam_role_policy_attachment.master_service_policy
  to   = aws_iam_role_policy_attachment.master_service_policy
}

moved {
  from = module.cluster.aws_iam_role.node
  to   = aws_iam_role.node
}

moved {
  from = module.cluster.aws_iam_role_policy_attachment.node_policy
  to   = aws_iam_role_policy_attachment.node_policy
}

moved {
  from = module.cluster.aws_iam_role_policy_attachment.node_cni_policy
  to   = aws_iam_role_policy_attachment.node_cni_policy
}

moved {
  from = module.cluster.aws_iam_role_policy_attachment.node_container_registry_ro
  to   = aws_iam_role_policy_attachment.node_container_registry_ro
}

moved {
  from = module.cluster.aws_iam_instance_profile.nodes
  to   = aws_iam_instance_profile.nodes
}

moved {
  from = module.cluster.aws_security_group.masters
  to   = aws_security_group.masters
}

moved {
  from = module.cluster.aws_security_group_rule.masters_ingress_apiserver_public
  to   = aws_security_group_rule.masters_ingress_apiserver_public
}

moved {
  from = module.cluster.aws_iam_openid_connect_provider.current
  to   = aws_iam_openid_connect_provider.current
}

moved {
  from = module.cluster.kubernetes_config_map.current
  to   = kubernetes_config_map.current
}

moved {
  from = module.cluster.aws_route53_zone.current
  to   = aws_route53_zone.current
}

moved {
  from = module.cluster.module.node_pool
  to   = module.node_pool
}
