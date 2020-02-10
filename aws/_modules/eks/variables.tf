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
  type = bool
  default = true
  description = "Will encrypted the root device."
}

variable "root_device_volume_size" {
  type = string
  default = "20"
  description = "Will set the volume size of the root device"
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
