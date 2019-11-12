resource "aws_security_group" "nodes" {
  name        = "${var.metadata_name}-node"
  description = "Security group for all nodes in the cluster"
  vpc_id      = aws_vpc.current.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.eks_metadata_tags
}

resource "aws_security_group_rule" "nodes_ingress_nodes" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.nodes.id
  source_security_group_id = aws_security_group.nodes.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "nodes_ingress_masters" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.nodes.id
  source_security_group_id = aws_security_group.masters.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "nodes_ingress_webhook" {
  description              = "Allow API server to reach injector endpoint"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.nodes.id
  source_security_group_id = aws_security_group.masters.id
  to_port                  = 443
  type                     = "ingress"
}
