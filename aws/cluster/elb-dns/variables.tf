variable "ingress_service_name" {
  type        = string
  description = "Metadata name of the ingress service."
}

variable "ingress_service_namespace" {
  type        = string
  description = "Metadata namespace of the ingress service."
}

variable "metadata" {
  type = object({
    name            = string
    domain          = string
    fqdn            = string
    labels          = map(string)
    label_namespace = string
    tags            = list(string)
  })
  description = "Cluster metadata from the common/metadata module."
}

variable "using_nlb" {
  type        = bool
  default     = false
  description = "Whether the ingress uses NLB or classic ELB."
}
