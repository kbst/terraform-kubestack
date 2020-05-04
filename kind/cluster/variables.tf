variable "configuration" {
  type        = map(map(string))
  description = "Map with per workspace cluster configuration."
}

variable "manifest_path" {
  type        = string
  description = "Path to Kustomize overlay to build."
  default     = null
}
