clusters = {
  gke_zero = {
    # apps environment
    apps = {
      # The Google cloud project ID to use
      project_id = ""

      # Set name_prefix used to generate the cluster_name
      # [name_prefix]-[workspace]-[region]
      # e.g. name_prefix = kbst becomes: `kbst-apps-europe-west3`
      # for small orgs the name works well,
      # for bigger orgs consider department or team names
      name_prefix = ""

      # Set the base_domain used to generate the FQDN of the cluster
      # [cluster_name].[provider_name].[base_domain]
      # e.g. kbst-apps-europe-west3.gcp.infra.example.com
      base_domain = ""

      # Initial desired K8s version, will be upgraded automatically
      cluster_min_master_version = "1.16"

      # Initial number of desired nodes per zone
      cluster_initial_node_count = 1

      # The Google cloud region to deploy the clusters in
      region = ""

      # Comma-separated list of zone names to deploy worker nodes in.
      # Must match region above.
      # e.g. cluster_node_locations = "europe-west3-a,europe-west3-b,europe-west3-c"
      # FIXME: Use actual list when TF 0.12 finally supports heterogeneous maps
      cluster_node_locations = ""
    }

    # ops environment, inherits from apps
    ops = {}

    # loc environment, inherits from apps
    loc = {}
  }
}
