variable "metadata_fqdn" {
  type        = "string"
  description = "DNS name of the zone. Requires dot at the end. E.g. example.com"
}

variable "template_string" {
  type        = "string"
  description = "Kubeconfig template to render."
}

variable "template_vars" {
  type        = "map"
  description = "Variables the kubeconfig template requires."
}
