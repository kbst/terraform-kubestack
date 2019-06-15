variable "name_prefix" {
  type        = string
  description = "String to prefix the name with."
}

variable "base_domain" {
  type        = string
  description = "Domain to use for the cluster."
}

variable "provider_name" {
  type        = string
  description = "Name of the cloud provider."
}

variable "provider_region" {
  type        = string
  description = "Name of the region."
}

variable "workspace" {
  type        = string
  description = "Name of the current workspace."
  default     = ""
}

variable "delimiter" {
  type        = string
  description = "Delimiter used between parts."
  default     = "-"
}

variable "label_namespace" {
  type        = string
  description = "Prefix labels are namespaced with."
  default     = "kubestack.com/"
}

