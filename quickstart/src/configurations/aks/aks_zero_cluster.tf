module "aks_zero" {
  source = "github.com/kbst/terraform-kubestack//azurerm/cluster?ref={{version}}"

  configuration = {
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

      # CNI/Advanced networking configuration parameters.
      # Leave commented for default 'kubenet' networking
      # vnet_address_space       = "10.16.0.0/12"  # accepts multiple comma-separated values
      # subnet_address_prefixes  = "10.18.0.0/16"  # accepts multiple comma-separated values
      # subnet_service_endpoints = null            # accepts multiple comma-separated values

      # network_plugin           = "azure"
      # network_policy           = "azure"
      # service_cidr             = "10.0.0.0/16"
      # dns_service_ip           = "10.0.0.10"
      # max_pods                 = 30
    }

    # ops environment, inherits from apps
    ops = {}

    # loc environment, inherits from apps
    loc = {}
  }
}
