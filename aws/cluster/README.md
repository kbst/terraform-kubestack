# Example usage

The cluster module is meant to be used to add an additional cluster e.g. in a
different region. As such it first requires to use the stack module to create
the first cluster and the infra (e.g. dns zone) which is then referenced in the
second cluster in the different region.

```
module "gcloud_stack" {
  source = "./platforms/gcloud/stack"

  project_name_prefix = "test"

  cluster_name_prefix        = "test"
  cluster_region             = "europe-west3"
  cluster_min_master_version = "1.11.2"
  cluster_initial_node_count = 1

  cluster_additional_zones = [
    "europe-west3-a",
    "europe-west3-b",
    "europe-west3-c",
  ]

  ingress_dns_name = "test.serverwolken.de."
}

module "gcloud_cluster" {
  source = "./platforms/gcloud/cluster"

  project_name_prefix = "pst"

  cluster_name_prefix        = "pst"
  cluster_region             = "europe-west1"
  cluster_min_master_version = "1.11.2"
  cluster_initial_node_count = 1

  dns_zone_project_id = "${module.gcloud_stack.dns_zone_project_id}"
  dns_zone_name       = "${module.gcloud_stack.dns_zone_name}"
  dns_zone_dns_name   = "${module.gcloud_stack.dns_zone_dns_name}"
}
```
