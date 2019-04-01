variable "metadata_name" {
  type        = "string"
  description = "Metadata name to use."
}

variable "metadata_fqdn" {
  type        = "string"
  description = "DNS name of the zone. Requires dot at the end. E.g. example.com"
}

variable "metadata_labels" {
  type        = "map"
  description = "Metadata labels to use."
}

variable "metadata_label_namespace" {
  type        = "string"
  description = "Prefix labels are namespaced with."
}

variable "resource_group" {
  type        = "string"
  description = "Resource group to use for the cluster."
}

variable "dns_prefix" {
  type        = "string"
  description = "DNS prefix of AKS cluster API server."
  default     = "api"
}

variable "agent_pool_profile_name" {
  type        = "string"
  description = "Name of agent pool profile."
  default     = "default"
}

variable "agent_pool_profile_count" {
  type        = "string"
  description = "Number of worker nodes"
  default     = "1"
}

variable "agent_pool_profile_vm_size" {
  type        = "string"
  description = "VM size of worker nodes"
  default     = "Standard_D1_v2"
}

variable "agent_pool_profile_os_type" {
  type        = "string"
  description = "OS type of worker nodes"
  default     = "Linux"
}

variable "agent_pool_profile_os_disk_size_gb" {
  type        = "string"
  description = "Disk size of worker nodes (in GB)"
  default     = "30"
}
