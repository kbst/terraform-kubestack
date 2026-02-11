# Moved blocks to maintain state compatibility after refactoring
# These blocks ensure that node pool resources are not recreated when upgrading
# from the old module structure to the new flattened structure.

moved {
  from = module.node_pool.aws_eks_node_group.nodes
  to   = aws_eks_node_group.nodes
}

moved {
  from = module.node_pool.aws_launch_template.current
  to   = aws_launch_template.current
}

moved {
  from = module.node_pool.data.aws_ec2_instance_type.current
  to   = data.aws_ec2_instance_type.current
}
