variable "project" {
  type        = "string"
  description = "Project the cluster belongs to."
}

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

variable "min_master_version" {
  type        = "string"
  description = "Minimum GKE master version."
}

variable "initial_node_count" {
  type        = "string"
  description = "Initial number of worker nodes in the cluster."
}

variable "additional_zones" {
  description = "List of additional_zones for workers."
  type        = "list"
}

variable "daily_maintenance_window_start_time" {
  type        = "string"
  description = "Start time of the daily maintenance window."
}

variable "extra_oauth_scopes" {
  description = "List of additional oauth scopes for workers."
  type        = "list"
}

variable "disk_size_gb" {
  type        = "string"
  description = "Disk size in GB for workers."
}

variable "disk_type" {
  type        = "string"
  description = "Disk type to use for workers."
}

variable "machine_type" {
  type        = "string"
  description = "Machine type to use for workers."
}
