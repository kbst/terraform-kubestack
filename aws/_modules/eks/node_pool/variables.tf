variable "metadata_labels" {
  type        = map(string)
  description = "Metadata labels to use."
}

variable "eks_metadata_tags" {
  type        = map(any)
  description = "EKS metadata tags to use."
}

variable "cluster_name" {
  type        = string
  description = "Cluster name of the EKS cluster."
}

variable "node_group_name" {
  type        = string
  description = "Name for this node pool."
}

variable "role_arn" {
  type        = string
  description = "ARN of the IAM role for worker nodes."
}

variable "instance_types" {
  type        = set(string)
  description = "Set of AWS instance types to use for nodes."
}

variable "desired_size" {
  type        = string
  description = "Desired number of worker nodes."
}

variable "max_size" {
  type        = string
  description = "Maximum number of worker nodes."
}

variable "min_size" {
  type        = string
  description = "Minimum number of worker nodes."
}

variable "disk_size" {
  type        = string
  default     = "20"
  description = "Will set the volume size of the root device"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of VPC subnet IDs to use for nodes."
}

variable "depends-on-aws-auth" {
  type        = map(string)
  description = "Used as a depends_on shim to first create the aws-auth configmap before creating the node_pool."
}

variable "taints" {
  type = set(object({
    key    = string
    value  = string
    effect = string
  }))
  description = "Kubernetes taints to set for node pool."
}

variable "tags" {
  type        = map(string)
  description = "AWS tags to set on the node pool. Merged with Kubestack default tags."
  default     = {}
}

variable "labels" {
  type        = map(string)
  description = "Kubernetes labels to set on the nodes created by the node pool. Merged with Kubestack default labels."
  default     = {}
}

variable "ami_type" {
  type        = string
  description = "AMI type to use for nodes of the node pool."
}

variable "ami_release_version" {
  type        = string
  description = "AMI version of the EKS Node Group. Defaults to latest version for Kubernetes version"
  default     = null
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version to use for node pool."
}

variable "metadata_options" {
  description = "EC2 metadata service options."
  type = object({
    http_endpoint               = optional(string)
    http_tokens                 = optional(string)
    http_put_response_hop_limit = optional(number)
    http_protocol_ipv6          = optional(string)
    instance_metadata_tags      = optional(string)
  })
}
