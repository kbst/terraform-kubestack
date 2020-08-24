variable "configuration" {
  type        = map(map(string))
  description = "Map with per workspace cluster configuration."
}

variable "base_key" {
  type        = string
  description = "The key in the configuration map all other keys inherit from."
}
