variable "metadata_labels" {
  type        = "map"
  description = "Cluster metadata."
}

variable "label_namespace" {
  type        = "string"
  description = "Prefix labels are namespaced with."
  default     = "kubestack.com/"
}

variable "cluster_type" {
  type        = "string"
  description = "Type of cluster to run kustomize build for."
}

variable "template_string" {
  type        = "string"
  description = "Kubeconfig template to render."
}

variable "template_vars" {
  type        = "map"
  description = "Variables the kubeconfig template requires."
}
