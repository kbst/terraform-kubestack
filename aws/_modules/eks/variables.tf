variable "organization" {
  type        = "string"
  description = "Organization the cluster belongs to."
}

variable "metadata_name" {
  type        = "string"
  description = "Metadata name to use."
}

variable "metadata_fqdn" {
  type        = "string"
  description = "DNS name of the zone. Requires dot at the end. E.g. example.com"
}

variable "metadata_labels" {
  type        = "map"
  description = "Metadata labels to use."
}

variable "region" {
  type        = "string"
  description = "AWS region to start the cluster in."
}

variable "availability_zones" {
  description = "List of availability_zones for workers."
  type        = "list"
}

variable "instance_type" {
  description = "AWS instance type to use for worker nodes."
  type        = "string"
}

variable "desired_capacity" {
  description = "Desired number of worker nodes."
  type        = "string"
}

variable "max_size" {
  description = "Maximum number of worker nodes."
  type        = "string"
}

variable "min_size" {
  description = "Minimum number of worker nodes."
  type        = "string"
}
