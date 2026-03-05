module "scw_zero" {
  source = "github.com/kbst/terraform-kubestack//scaleway/cluster?ref={{version}}"

  configuration = {
    # apps environment
    apps = {
      # Set name_prefix used to generate the cluster name
      # [name_prefix]-[workspace]-[region]
      # e.g. name_prefix = kbst becomes: `kbst-apps-fr-par`
      # for small orgs the name works well,
      # for bigger orgs consider department or team names
      name_prefix = ""

      # Set the base_domain used to generate the FQDN of the cluster
      # [cluster_name].[provider_name].[base_domain]
      # e.g. kbst-apps-fr-par.scw.infra.example.com
      # The domain must be registered with Scaleway Domains and DNS
      base_domain = ""

      # The Scaleway region to deploy the cluster in
      # Uncomment and set to your target region, e.g:
      # region = "fr-par"

      # Kubernetes version for the cluster
      # Use a minor version string to allow patch upgrades, e.g. "1.35"
      cluster_version = "1.35"

      default_node_pool = {
        # Commercial node type — must be available in every zone listed below.
        # Run `scw k8s node-pool list-available-types` to list types per zone.
        node_type = "PRO2-XXS"

        # Availability zones to distribute the default node pool across.
        # One pool is created per zone. Must be explicitly specified.
        # fr-par: zones = ["fr-par-1", "fr-par-2", "fr-par-3"]
        # nl-ams: zones = ["nl-ams-1", "nl-ams-2", "nl-ams-3"]
        # pl-waw: zones = ["pl-waw-1", "pl-waw-2", "pl-waw-3"]
        # zones = ["fr-par-1", "fr-par-2", "fr-par-3"]

        min_size = 1
        max_size = 2
      }
    }

    # ops environment, inherits from apps
    ops = {}
  }
}
