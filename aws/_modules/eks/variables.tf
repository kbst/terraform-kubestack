variable "metadata_name" {
  type        = string
  description = "Metadata name to use."
}

variable "metadata_fqdn" {
  type        = string
  description = "DNS name of the zone. E.g. `infra.example.com`"
}

variable "metadata_labels" {
  type        = map(string)
  description = "Metadata labels to use."
}

variable "availability_zones" {
  description = "List of availability_zones for workers."
  type        = list(string)
}

variable "instance_type" {
  description = "AWS instance type to use for worker nodes."
  type        = string
}

variable "desired_capacity" {
  description = "Desired number of worker nodes."
  type        = string
}

variable "max_size" {
  description = "Maximum number of worker nodes."
  type        = string
}

variable "min_size" {
  description = "Minimum number of worker nodes."
  type        = string
}

variable "root_device_encrypted" {
  type        = bool
  default     = true
  description = "Whether to encrypt root device volumes of worker nodes."
}

variable "root_device_volume_size" {
  type        = number
  default     = 20
  description = "Size in GB for root device volumes of worker nodes."
}

variable "aws_auth_map_roles" {
  description = "mapRoles entries added to aws-auth configmap"
  type        = string
}

variable "aws_auth_map_users" {
  description = "mapUsers entries added to aws-auth configmap"
  type        = string
}

variable "aws_auth_map_accounts" {
  description = "mapAccounts entries added to aws-auth configmap"
  type        = string
}

variable "manifest_path" {
  type        = string
  description = "Path to Kustomize overlay to build."
}

variable "disable_default_ingress" {
  type        = bool
  description = "Whether to disable the default ingress."
}

variable "enabled_cluster_log_types" {
  type        = list(string)
  description = "List of cluster log types to enable."
}

variable "disable_openid_connect_provider" {
  type        = bool
  description = "Whether to disable the OpenID connect provider."
}

variable "cluster_version" {
  type        = string
  default     = null
  description = "The version of the cluster (defaults to latest available)"
}
