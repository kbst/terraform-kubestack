variable "metadata_name" {
  type        = string
  description = "Metadata name to use."
}

variable "metadata_fqdn" {
  type        = string
  description = "DNS name of the zone. Requires dot at the end. E.g. example.com"
}

variable "metadata_labels" {
  type        = map(string)
  description = "Metadata labels to use."
}

variable "metadata_label_namespace" {
  type        = string
  description = "Prefix labels are namespaced with."
}

variable "resource_group" {
  type        = string
  description = "Resource group to use for the cluster."
}

variable "dns_prefix" {
  type        = string
  description = "DNS prefix of AKS cluster API server."
  default     = "api"
}

variable "default_node_pool_name" {
  type        = string
  description = "Name of default node pool."
  default     = "default"
}

variable "default_node_pool_type" {
  type        = string
  description = "Type of default node pool. Defaults to VirtualMachineScaleSets, use AvailabilitySet for backwards compatibility with older clusters."
  default     = "VirtualMachineScaleSets"
}

variable "default_node_pool_enable_auto_scaling" {
  type        = bool
  description = "Wether to enable auto scaling for the default node pool. Defaults to true."
  default     = true
}

variable "default_node_pool_min_count" {
  type        = string
  description = "Min number of worker nodes"
  default     = "1"
}

variable "default_node_pool_max_count" {
  type        = string
  description = "Max number of worker nodes"
  default     = "1"
}

variable "default_node_pool_node_count" {
  type        = string
  description = "Static number of worker nodes"
  default     = "1"
}

variable "default_node_pool_vm_size" {
  type        = string
  description = "VM size of worker nodes"
  default     = "Standard_D1_v2"
}

variable "default_node_pool_os_disk_size_gb" {
  type        = string
  description = "Disk size of worker nodes (in GB)"
  default     = "30"
}

variable "manifest_path" {
  type        = string
  description = "Path to Kustomize overlay to build."
}

variable "disable_default_ingress" {
  type        = bool
  description = "Whether to disable the default ingress."
}

variable "service_principal_end_date_relative" {
  type        = string
  description = "Relative time in hours for which the service principal password is valid. Defaults to 1 year."
}
