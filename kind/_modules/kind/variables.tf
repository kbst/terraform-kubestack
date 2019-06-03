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

variable "node_roles" {
  type        = "string"
  description = "Comma seperated list of node roles. E.g. 'control-plan,worker'"
}
