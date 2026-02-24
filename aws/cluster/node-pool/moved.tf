moved {
  from = module.node_pool.aws_eks_node_group.nodes
  to   = aws_eks_node_group.nodes
}

moved {
  from = module.node_pool.aws_launch_template.current
  to   = aws_launch_template.current
}
