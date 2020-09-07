clusters = {
  aks_zero = {
    # apps envrionment configuration
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

      # The Azure resource group to use
      resource_group = ""
    }

    # ops environment, inherrits from apps
    ops = {}

    # loc environment, inherrits from apps
    loc = {}
  }
}
