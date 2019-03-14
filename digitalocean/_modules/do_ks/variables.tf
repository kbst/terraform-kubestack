variable "metadata_name" {
  type        = "string"
  description = "Metadata name to use."
}

variable "metadata_fqdn" {
  type        = "string"
  description = "DNS name of the zone. Requires dot at the end. E.g. example.com"
}

variable "metadata_tags" {
  type        = "list"
  description = "Metadata tags to use."
}

variable "metadata_labels" {
  type        = "map"
  description = "Metadata labels to use."
}

variable "region" {
  type        = "string"
  description = "Google cloud region to start the cluster in."
}

variable "initial_node_count" {
  type        = "string"
  description = "Initial number of worker nodes in the cluster."
}

variable "cluster_machine_type" {
  type        = "string"
  description =  "Machine type to use for workers."
}

variable "cluster_min_master_version" {
  type        = "string"
  description =  "Machine type to use for workers."
}

