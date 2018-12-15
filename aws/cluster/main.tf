module "cluster_metadata" {
  source = "../../common/metadata"

  name_prefix = "${var.name_prefix}"
  base_domain = "${var.base_domain}"

  provider_name   = "aws"
  provider_region = "${var.region}"
}

module "cluster" {
  source = "../_modules/eks"

  organization = "${var.organization}"
  region       = "${var.region}"

  metadata_name   = "${module.cluster_metadata.name}"
  metadata_fqdn   = "${module.cluster_metadata.fqdn}"
  metadata_labels = "${module.cluster_metadata.labels}"

  availability_zones = "${var.cluster_availability_zones}"
  instance_type      = "${var.cluster_instance_type}"
  desired_capacity   = "${var.cluster_desired_capacity}"
  max_size           = "${var.cluster_max_size}"
  min_size           = "${var.cluster_min_size}"
}
