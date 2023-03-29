module "eks_zero" {
  providers = {
    aws        = aws.eks_zero
    kubernetes = kubernetes.eks_zero
  }

  source = "../aws/cluster"

  configuration = {
    # Settings for Apps-cluster
    apps = {
      name_prefix                = "kbstacctest"
      base_domain                = "infra.serverwolken.de"
      cluster_instance_type      = "t3a.medium"
      cluster_desired_capacity   = "1"
      cluster_min_size           = "1"
      cluster_max_size           = "1"
      cluster_availability_zones = "eu-west-1a,eu-west-1b,eu-west-1c"

      cluster_aws_auth_map_users = <<MAPUSERS
      - userarn: arn:aws:iam::694714331404:user/pst
        username: pst
        groups:
        - system:masters
      MAPUSERS
    }

    # Settings for Ops-cluster
    ops = {
      cluster_max_size           = "1"
      cluster_availability_zones = "eu-west-1a,eu-west-1b"
    }
  }
}
