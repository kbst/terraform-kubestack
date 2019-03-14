clusters = {
  do_ks_zero = {
    # Settings for Apps-cluster
    apps = {
      # Set name_prefix used to generate the cluster_name
      # [name_prefix]-[workspace]-[region]
      # e.g. name_prefix = kbst becomes: `kbst-apps-europe-west3`
      # for small orgs the name works well,
      # for bigger orgs consider department or team names
      name_prefix = ""

      # Set the base_domain used to generate the FQDN of the cluster
      # [cluster_name].[provider_name].[base_domain]
      # e.g. kbst-ops-europe-west3.gcp.infra.example.com
      base_domain = ""

      # Initial desired K8s version, will be upgraded automatically
      cluster_min_master_version = "1.13.0-do.1"

      # Initial number of desired nodes per zone
      cluster_initial_node_count = 3

      # The Digital Ocean region to deploy the clusters in
      region = "nyc1"
      cluster_machine_type = "s-2vcpu-2gb"
    }

    # Settings for Ops-cluster
    # configuration here overwrites the values from apps
    ops = {

    }
  }
}
