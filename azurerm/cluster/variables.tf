variable "configuration" {
  type        = map(map(string))
  description = "Map with per workspace cluster configuration."
}

variable "configuration_base_key" {
  type        = string
  description = "The key in the configuration map all other keys inherit from."
  default     = "apps"
}

variable "manifest_path" {
  type        = string
  description = "Path to Kustomize overlay to build."
  default     = null
}

variable "vnet_subnet_id" {
  type        = string
  description = "ID of the subnet for the cluster nodepool, if using CNI for networking."
  default     = null
}
