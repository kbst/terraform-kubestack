variable "configuration" {
  type        = map(map(string))
  description = "Map with per workspace cluster configuration."
}

variable "manifest_path" {
  type        = string
  description = "Path to Kustomize overlay to build."
  default     = null
}

variable "base_key" {
  type        = string
  description = "The key in the configuration map all other keys inherit from."
  default     = "apps"
}
