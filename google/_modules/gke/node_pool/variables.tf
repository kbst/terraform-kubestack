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

variable "pool_name" {
  description = "Name of the node pool."
  type        = "string"
}

variable "location" {
  type        = "string"
  description = "location of the cluster this node pool belongs to."
}

variable "initial_node_count" {
  description = "Initial number of nodes for this node pool."
  type        = "string"
}

variable "min_node_count" {
  description = "Min number of nodes for this node pool."
  type        = "string"
}

variable "max_node_count" {
  description = "Max number of nodes for this node pool."
  type        = "string"
}

variable "service_account_email" {
  description = "The service account email to use for this node pool."
  type        = "string"
}

variable "extra_oauth_scopes" {
  description = "List of additional oauth scopes for workers."
  type        = "list"
}

variable "disk_size_gb" {
  description = "The disk size of nodes in this pool."
  type        = "string"
}

variable "disk_type" {
  description = "The disk type of nodes in this pool."
  type        = "string"
}

variable "image_type" {
  description = "The image type for nodes in this pool."
  type        = "string"
  default     = "COS"
}

variable "machine_type" {
  description = "The machine type for nodes in this pool."
  type        = "string"
}

variable "preemptible" {
  description = "Whether to use preemptible nodes for this node pool."
  type        = "string"
  default     = false
}

variable "auto_repair" {
  description = "Whether the nodes will be automatically repaired."
  type        = "string"
  default     = true
}

variable "auto_upgrade" {
  description = "Whether the nodes will be automatically upgraded."
  type        = "string"
  default     = true
}
