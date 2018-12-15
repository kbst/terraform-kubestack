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

variable "project_id" {
  type        = "string"
  description = "IF of the project to use for resources."
}

variable "region" {
  type        = "string"
  description = "Google cloud region to use for resources in."
}

#
#
# Cluster variables
variable "cluster_min_master_version" {
  type        = "string"
  description = "Minimum GKE master version."
}

variable "cluster_initial_node_count" {
  type        = "string"
  description = "Initial number of worker nodes in the cluster."
}

variable "cluster_additional_zones" {
  description = "List of additional_zones for workers."
  type        = "list"
  default     = []
}

variable "cluster_daily_maintenance_window_start_time" {
  type        = "string"
  description = "Start time of the daily maintenance window."
  default     = "03:00"
}

variable "cluster_extra_oauth_scopes" {
  description = "List of additional oauth scopes for workers."
  type        = "list"
  default     = []
}

variable "cluster_disk_size_gb" {
  type        = "string"
  description = "Disk size in GB for workers."
  default     = 100
}

variable "cluster_disk_type" {
  type        = "string"
  description = "Disk type to use for workers."
  default     = "pd-standard"
}

variable "cluster_machine_type" {
  type        = "string"
  description = "Machine type to use for workers."
  default     = ""
}
