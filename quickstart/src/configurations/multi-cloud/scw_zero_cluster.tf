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

      # The Scaleway region to deploy the clusters in
      # e.g. "fr-par", "nl-ams", "pl-waw"
      region = ""

      # Kubernetes version for the cluster
      # Use a minor version string to allow patch upgrades, e.g. "1.32"
      cluster_version = "1.32"

      # Container Network Interface plugin
      # Options: "cilium", "calico", "weave", "flannel", "kilo"
      cni = "cilium"

      # Whether to delete additional resources (load-balancers, block volumes,
      # the private network if empty) created in Kubernetes when deleting the cluster.
      # Set to true only if you want these resources cleaned up automatically on destroy.
      delete_additional_resources = false

      # Default node pool configuration
      default_node_pool = {
        # Commercial node type — see `scw k8s node-pool list-available-types`
        node_type = "DEV1-M"

        # Initial number of nodes in the pool
        size = 1

        # Minimum and maximum size for autoscaling
        min_size = 1
        max_size = 1

        # Enable Scaleway's cluster autoscaler for this pool
        autoscaling = false

        # Enable automatic node replacement on failure
        autohealing = true
      }
    }

    # ops environment, inherits from apps
    ops = {}
  }
}
