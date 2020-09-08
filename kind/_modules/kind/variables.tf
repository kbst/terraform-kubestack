variable "metadata_name" {
  type        = string
  description = "Metadata name to use."
}

variable "metadata_fqdn" {
  type        = string
  description = "DNS name of the zone. Requires dot at the end. E.g. example.com"
}

variable "metadata_tags" {
  type        = list(string)
  description = "Metadata tags to use."
}

variable "metadata_labels" {
  type        = map(string)
  description = "Metadata labels to use."
}

variable "extra_nodes" {
  type        = string
  description = "Comma seperated list of node roles. E.g. 'control-plan,worker'"
}

variable "http_port" {
  type        = string
  description = "Port to bind on localhost for http ingress."
}

variable "https_port" {
  type        = string
  description = "Port to bind on localhost for https ingress."
}

variable "node_image" {
  type        = string
  description = "Docker image kind will use to boot the cluster nodes. Defaults to 'kindest/node:v1.16.1'"
}

variable "manifest_path" {
  type        = string
  description = "Path to Kustomize overlay to build."
}

variable "disable_default_ingress" {
  type        = bool
  description = "Whether to disable the default ingress."
}
