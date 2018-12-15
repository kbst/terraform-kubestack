#
#
# Common variables
variable "name_prefix" {
  type        = "string"
  description = "Prefix to start the generated name with, e.g. kbst."
}

variable "base_domain" {
  type        = "string"
  description = "The base domain to use for all fqdn's, e.g. infra.example.com."
}

variable "region" {
  type        = "string"
  description = "Google cloud region to start the cluster in."
}

variable "organization" {
  type        = "string"
  description = "Organization the cluster belongs to."
}

#
#
# Cluster variables
variable "cluster_availability_zones" {
  description = "List of availability_zones for workers."
  type        = "list"
}

variable "cluster_instance_type" {
  description = "AWS instance type to use for worker nodes."
  type        = "string"
}

variable "cluster_desired_capacity" {
  description = "Desired number of worker nodes."
  type        = "string"
}

variable "cluster_max_size" {
  description = "Maximum number of worker nodes."
  type        = "string"
}

variable "cluster_min_size" {
  description = "Minimum number of worker nodes."
  type        = "string"
}
