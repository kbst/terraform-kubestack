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

variable "metadata_label_namespace" {
  type        = string
  description = "Prefix labels are namespaced with."
}

variable "resource_group" {
  type        = string
  description = "Resource group to use for the cluster."
}

variable "legacy_vnet_name" {
  type        = bool
  description = "Wheter to use the legacy vnet and subnet names."
  default     = false
}

variable "vnet_address_space" {
  type        = list(string)
  description = "Address space for the virtual network."
}

variable "subnet_address_prefixes" {
  type        = list(string)
  description = "Address space for the cluster subnet."
}

variable "subnet_service_endpoints" {
  type        = list(string)
  description = "List of service endpoints to expose on the subnet."
}

variable "network_plugin" {
  type        = string
  description = "Network plugin to use. Set to 'azure' for CNI; 'kubenet' for Basic"
}

variable "network_policy" {
  type        = string
  description = "Network policy to use. Set to 'azure' for CNI; 'calico' for Basic"
}

variable "dns_prefix" {
  type        = string
  description = "DNS prefix of AKS cluster API server."
  default     = "api"
}

variable "service_cidr" {
  type        = string
  description = "CIDR range for kubernetes service."
}

variable "dns_service_ip" {
  type        = string
  description = "IP address for the kube-dns service. Must be within service_cidr."
}

variable "pod_cidr" {
  type        = string
  description = "CIDR range for pods."
}

variable "max_pods" {
  type        = number
  description = "Maximum number of pods to run per node, if using CNI for networking."
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

variable "default_node_pool_only_critical_addons" {
  type        = bool
  description = "Enabling will taint default node pool with CriticalAddonsOnly=true:NoSchedule taint. Changing this forces a new resource to be created."
  default     = false
}

variable "disable_default_ingress" {
  type        = bool
  description = "Whether to disable the default ingress."
}

variable "default_ingress_ip_zones" {
  type        = list(string)
  description = "Explicit list of zones for the ingress public IP."
}

variable "enable_azure_policy_agent" {
  type        = bool
  description = "whether to deploy the Azure policy agent to the cluster"
  default     = false
}

variable "disable_managed_identities" {
  type        = bool
  description = "Keep using legacy service principal instead of new managed identities."
  default     = false
}

variable "user_assigned_identity_id" {
  type        = string
  description = "ID of the UserAssigned identity to use."
  default     = null
}

variable "sku_tier" {
  type        = string
  description = "The SKU tier to use for the cluster. Possible values are 'Free' and 'Paid'. Defaults to 'Free'."
  default     = "Free"
}

variable "kubernetes_version" {
  type        = string
  description = "Version of Kubernetes to use when creating the cluster. If not specified, latest version will be used."
}

variable "automatic_channel_upgrade" {
  type        = string
  description = "The upgrade channel for this Kubernetes Cluster. Possible values are 'patch', 'rapid', 'node-image' and 'stable'."
}

variable "enable_log_analytics" {
  type        = bool
  description = "whether to deploy the Azure Log analytics with the cluster"
  default     = true
}

variable "availability_zones" {
  type        = list(string)
  description = "The list of availability zones to create the node pool in"
  default     = []
}


variable "keda_enabled" {
  type        = bool
  description = "Whether KEDA Autoscaler should be enabled for the cluster."
  default     = false
}

variable "vertical_pod_autoscaler_enabled" {
  type        = bool
  description = "Whether Vertical Pod Autoscaler should be enabled for the cluster."
  default     = false
}