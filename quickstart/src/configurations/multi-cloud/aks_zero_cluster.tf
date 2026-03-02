module "aks_zero" {
  source = "github.com/kbst/terraform-kubestack//azurerm/cluster?ref={{version}}"

  configuration = {
    # Settings for Apps-cluster
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
      # resource_group = "my-resource-group"

      # Availability zones to distribute the cluster across.
      # Must be a list of zone numbers as strings.
      # availability_zones = ["1", "2", "3"]

      # Default node pool configuration
      default_node_pool = {
        # Azure VM size for the default node pool nodes.
        # vm_size = "Standard_B2s"

        # Minimum and maximum node count for autoscaling
        min_count = 1
        max_count = 1
      }
    }

    # Settings for Ops-cluster
    ops = {}
  }
}
