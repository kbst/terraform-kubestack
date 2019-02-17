clusters = {
  eks_zero = {
    # Settings for Apps-cluster
    apps = {
      # Set name_prefix used to generate the cluster_name
      # [name_prefix]-[workspace]-[region]
      # e.g. name_prefix = kbst becomes: `kbst-ops-eu-west-1`
      # for small orgs the name works well
      # for bigger orgs consider department or team names
      name_prefix = ""

      # Set the base_domain used to generate the FQDN of the cluster
      # [cluster_name].[provider_name].[base_domain]
      # e.g. kbst-ops-eu-west-1.aws.infra.example.com
      base_domain = ""

      cluster_instance_type    = "t2.small"
      cluster_desired_capacity = "1"
      cluster_min_size         = "1"
      cluster_max_size         = "3"

      # Comma seperated list of zone names to deploy worker nodes in
      # EKS requires a min. of 2 zones
      # Must match region set in provider
      # e.g. cluster_availability_zones = "eu-west-1a,eu-west-1b,eu-west-1c"
      # FIXME: Use actual list when TF 0.12 finally supports heterogeneous maps
      cluster_availability_zones = ""
    }

    # Settings for Ops-cluster
    ops = {
      # Overwrite apps["cluster_availability_zones"] to have a smaller
      # ops cluster
      # EKS requires a min. of 2 zones
      # e.g. cluster_availability_zones = "eu-west-1a,eu-west-1b"
      cluster_availability_zones = ""
    }
  }
}
