variable "metadata_name" {
  type        = "string"
  description = "Metadata name to use."
}

variable "cluster_version" {
  type        = "string"
  description = "Kubernetes version of the EKS cluster."
}

variable "cluster_endpoint" {
  type        = "string"
  description = "Kubernetes API endpoint of the EKS cluster."
}

variable "cluster_ca" {
  type        = "string"
  description = "Certificate authority of the EKS cluster."
}

variable "cluster_name" {
  type        = "string"
  description = "Cluster name of the EKS cluster."
}

variable "iam_instance_profile_name" {
  type        = "string"
  description = "IAM instance profile to use for nodes."
}

variable "instance_type" {
  type        = "string"
  description = "AWS instance type to use for nodes."
}

variable "security_groups" {
  type        = "list"
  description = "List of security group IDs to use for nodes."
}

variable "desired_capacity" {
  type        = "string"
  description = "Desired number of worker nodes."
}

variable "max_size" {
  type        = "string"
  description = "Maximum number of worker nodes."
}

variable "min_size" {
  type        = "string"
  description = "Minimum number of worker nodes."
}

variable "vpc_zone_identifiers" {
  type        = "list"
  description = "List of VPC subnet IDs to use for nodes."
}
