variable "metadata_name" {
  type        = "string"
  description = "Metadata name to use."
}

variable "metadata_tags" {
  type        = "list"
  description = "Metadata tags to use."
}

variable "metadata_labels" {
  type        = "map"
  description = "Metadata labels to use."
}

variable "services" {
  type        = "list"
  description = "List of services to enable for the project"
}
