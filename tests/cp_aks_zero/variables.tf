variable "clusters" {
  description = "Map, holding configuration of all clusters."
  type        = map(map(map(string)))
}
