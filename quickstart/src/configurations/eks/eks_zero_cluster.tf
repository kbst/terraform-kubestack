module "eks_zero" {
  providers = {
    aws        = aws.eks_zero
    kubernetes = kubernetes.eks_zero
  }

  source = "github.com/kbst/terraform-kubestack//aws/cluster?ref={{version}}"

  configuration = {
    # apps environment
    apps = {
      # Set name_prefix used to generate the cluster_name
      # [name_prefix]-[workspace]-[region]
      # e.g. name_prefix = kbst becomes: `kbst-apps-eu-west-1`
      # for small orgs the name works well
      # for bigger orgs consider department or team names
      name_prefix = ""

      # Set the base_domain used to generate the FQDN of the cluster
      # [cluster_name].[provider_name].[base_domain]
      # e.g. kbst-apps-eu-west-1.aws.infra.example.com
      base_domain = ""

      default_node_pool = {
        instance_types   = ["t3.small"]
        desired_capacity = 1
        min_size         = 1
        max_size         = 1
      }

      # EKS requires a min. of 2 zones
      # Must match region set in provider
      # e.g. cluster_availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
      cluster_availability_zones = []
    }

    # ops environment, inherits from apps
    ops = {}
  }
}
