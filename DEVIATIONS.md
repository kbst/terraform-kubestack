# Kubestack DEVIATIONS.md — Known Divergences and Exceptions

> This file is referenced by `AGENTS.md`.
> When adding a new divergence or exception, follow the formats defined in each section below.

## Current Divergences

Divergences are places where the current module implementation does not yet comply with a rule in AGENTS.md. Every divergence has a planned resolution. Do not work around a divergence silently — if a task requires touching code covered by a divergence, note it in the PR description.

When a divergence is resolved, remove its entry from this file.

### Format

> **Divergence — `<path/to/module>` (or "All modules"):** `<rule reference>` — `<one sentence describing what the implementation currently does instead>`. Planned resolution: `<what will change and when>`.

### Entries

> **Divergence — All cluster and node-pool modules:** Node Pool Lifecycle — instance type and `min`/`max` node counts — existing modules set hardcoded defaults for instance type and `min`/`max` node counts, violating the rule that these must always be user-provided with no module default. Planned resolution: defaults will be removed in the v1 release.

> **Divergence — `azurerm/cluster`:** Cluster API Authentication — the kubeconfig output uses a client certificate issued via `kube_admin_config` rather than a short-lived Azure AD / Entra ID token, violating the rule that static long-lived credentials must be disabled. Planned resolution: switch to Azure AD / Entra ID token-based authentication in the v1 release.

> **Divergence — `azurerm/cluster`:** Networking — the VNet and subnet are only created when `network_plugin = "azure"`; when the default `"kubenet"` plugin is used no dedicated network resources are provisioned by the module, violating the rule that every cluster module MUST create its own dedicated network resources. Planned resolution: always provision a VNet and subnet in the v1 release.

> **Divergence — `azurerm/cluster`:** Networking — CIDR Defaults — `service_cidr`, `dns_service_ip`, and `pod_cidr` are given hardcoded Kubestack defaults (`10.0.0.0/16`, `10.0.0.10`, `10.244.0.0/16`) even though AKS accepts but does not require these arguments; the rule requires passing `null` to let the provider apply its own defaults. Planned resolution: remove the hardcoded defaults and pass `null` in the v1 release.

> **Divergence — `azurerm/cluster`:** Cross-Provider Developer Experience — there is no `region` configuration attribute; the Azure region is derived from `data.azurerm_resource_group.current.location` rather than being exposed as a required configuration attribute with a `precondition`. Planned resolution: add a `region` configuration attribute and precondition in the v1 release.

> **Divergence — `azurerm/cluster`:** Configuration Inheritance — `precondition` lifecycle blocks are absent from `azurerm_kubernetes_cluster` for required attributes (`resource_group`, `availability_zones`, `vm_size`, `min_count`, `max_count`), violating the rule that required attributes with no module default must be guarded by a precondition on the primary resource. Planned resolution: add preconditions in the v1 release.

> **Divergence — `azurerm/cluster/node-pool`:** Configuration Inheritance — `precondition` lifecycle blocks are absent from `azurerm_kubernetes_cluster_node_pool` for required attributes (`availability_zones`, `vm_size`, `min_count`, `max_count`), violating the rule that required attributes with no module default must be guarded by a precondition on the primary resource. Planned resolution: add preconditions in the v1 release.

> **Divergence — `azurerm/cluster`:** Tagging and Labelling — the cluster module exposes `additional_metadata_labels` for user-supplied tags on cloud resources; the upstream `azurerm_kubernetes_cluster` resource argument is `tags`, so the configuration attribute should be named `tags` to mirror it. Planned resolution: rename to `tags` in the v1 release.

> **Divergence — `azurerm/cluster/node-pool`:** Tagging and Labelling — `azurerm_kubernetes_cluster_node_pool` has no `tags` block applying metadata labels, violating the rule that all cloud resources MUST be tagged using the metadata module output. Planned resolution: add `cluster_metadata` variable and a `tags` argument referencing its labels in the v1 release.

> **Divergence — `azurerm/cluster/node-pool`:** Node-Pool Module Variables — the node-pool module does not define a `cluster_metadata` input variable, violating the standard node-pool contract which requires both `cluster` and `cluster_metadata` variables. Planned resolution: add `cluster_metadata` variable and use it for resource tagging in the v1 release.

> **Divergence — `azurerm/cluster`:** Cloud Provider Isolation — `azurerm_log_analytics_workspace` and `azurerm_log_analytics_solution` are provisioned and the OMS agent is enabled by default (`enable_log_analytics` defaults to `true`), violating the rule that cluster-level add-ons MUST be disabled by default unless required for self-healing or auto-scaling. Planned resolution: flip the default to `false` in the v1 release.

> **Divergence — `azurerm/cluster`:** Cluster Module Outputs — the cluster module exposes `aks_vnet` and `default_ingress_ip` outputs beyond the four required outputs, without compelling provider-specific justification. Planned resolution: evaluate for removal in the v1 release.

> **Divergence — `aws/cluster`:** Networking — nodes are assigned public IPs by default (`map_public_ip_on_launch = true` is the default when `cluster_vpc_subnet_map_public_ip` is unset), violating the rule that nodes MUST be configured with private IPs only by default and egress MUST route through NAT gateways. Planned resolution: flip the default to private nodes with NAT gateway egress in the v1 release.

> **Divergence — `aws/cluster`:** Cross-Provider Developer Experience — there is no `region` configuration attribute; the AWS region is sourced entirely from the provider configuration rather than being exposed as a required configuration attribute with a `precondition`. Planned resolution: add a `region` configuration attribute and precondition in the v1 release.

> **Divergence — `aws/cluster`:** Configuration Inheritance — `precondition` lifecycle blocks are absent from `aws_eks_cluster` for required attributes (`cluster_availability_zones`), violating the rule that required attributes with no module default must be guarded by a precondition on the primary resource. Planned resolution: add preconditions in the v1 release.

> **Divergence — `aws/cluster/node-pool`:** Configuration Inheritance — `precondition` lifecycle blocks are absent from `aws_eks_node_group` for required attributes (`availability_zones`, `instance_types`, `min_size`, `max_size`), violating the rule that required attributes with no module default must be guarded by a precondition on the primary resource. Planned resolution: add preconditions in the v1 release.

> **Divergence — `aws/cluster`:** Tagging and Labelling — user-supplied cloud resource tags are only configurable via `additional_node_tags` nested inside `default_node_pool`, meaning there is no top-level `tags` attribute on the cluster configuration object and extra-node-pool resources (VPC, subnets, security groups, etc.) cannot receive user-supplied tags. Planned resolution: add a top-level `tags` attribute to the cluster configuration in the v1 release.

> **Divergence — `aws/cluster/node-pool`:** Tagging and Labelling — the node-pool `labels` configuration attribute is not applied to the Kubernetes node object's `.metadata.labels`; EKS node group labels are set on the cloud API only, violating the rule that node labels MUST be applied to both the cloud API and the Kubernetes node object. Planned resolution: apply labels to both APIs in the v1 release.

> **Divergence — `aws/cluster`:** Human User Authentication — the `cluster_aws_auth_map_roles` and `cluster_aws_auth_map_users` configuration attributes allow arbitrary IAM-to-RBAC mappings to be injected into the `aws-auth` ConfigMap via the module, making the module a conduit for cluster-level RBAC bindings for named human users, which AGENTS.md reserves for platform service modules or the platform operator. Planned resolution: remove `cluster_aws_auth_map_roles` and `cluster_aws_auth_map_users` from the module interface in the v1 release.

> **Divergence — `google/cluster`:** Networking — `google_compute_network` is created with `auto_create_subnetworks = true`, which auto-creates unmanaged subnets across all GCP regions rather than the module provisioning its own explicit, Terraform-managed subnet resources. Planned resolution: set `auto_create_subnetworks = false` and add explicit `google_compute_subnetwork` resources in `network.tf` in the v1 release.

> **Divergence — `google/cluster`:** Tagging and Labelling — `google_container_cluster` has no `resource_labels` block, and `google_compute_network`, `google_compute_router`, `google_compute_address`, and `google_dns_managed_zone` resources in `network.tf` and `ingress.tf` have no labels from the `common/metadata` output, violating the rule that all cloud resources MUST be tagged/labelled using the metadata module output. Planned resolution: add `resource_labels` (or equivalent) referencing `module.cluster_metadata.labels` to all cloud resources in the v1 release.

> **Divergence — `google/cluster/node-pool`:** Tagging and Labelling — the merge order in `node_config.labels` is `merge(cfg.labels, cluster_metadata.labels)`, placing metadata labels last so they override user-supplied labels, which is the inverse of the required precedence (metadata labels → user-supplied cloud resource labels → user-supplied node labels → mandatory provider labels). Planned resolution: fix the merge order in the v1 release.

> **Divergence — `google/cluster`:** Configuration Inheritance — `precondition` lifecycle blocks are absent from `google_container_cluster` for required attributes (`region`, `project_id`), violating the rule that required attributes with no module default must be guarded by a precondition on the primary resource. Planned resolution: add preconditions in the v1 release.

> **Divergence — `google/cluster/node-pool`:** Configuration Inheritance — `precondition` lifecycle blocks are absent from `google_container_node_pool` for required attributes (`location`, `machine_type`, `min_node_count`, `max_node_count`), violating the rule that required attributes with no module default must be guarded by a precondition on the primary resource. Planned resolution: add preconditions in the v1 release.

> **Divergence — `google/cluster/node-pool`:** Node Pool Lifecycle — `google_container_node_pool` sets `initial_node_count` but has no `lifecycle { ignore_changes = [initial_node_count] }` block, violating the rule that the desired/initial node count must be owned by the autoscaler and not managed by OpenTofu/Terraform state. Planned resolution: add the `lifecycle` ignore block in the v1 release.

> **Divergence — `google/cluster/node-pool`:** Node Pool Lifecycle — `machine_type` defaults to `""` (empty string) via `try(coalesce(local.cfg.machine_type, null), "")`, which the GCP provider interprets as a provider-level default, violating the rule that instance type must always be user-provided with no module default. Planned resolution: remove the empty-string default in the v1 release (covered by the existing "All cluster and node-pool modules" divergence but noted here for the specific empty-string mechanism).

> **Divergence — `google/cluster`:** Cluster Module Outputs — the cluster module exposes a `default_ingress_ip` output beyond the four required outputs, without a compelling provider-specific justification. Planned resolution: evaluate for removal in the v1 release.

> **Divergence — `google/cluster/node-pool`:** Node-Pool Module Outputs — the node-pool module exposes an `id` output beyond the single required `current_config` output, without a compelling provider-specific justification. Planned resolution: evaluate for removal in the v1 release.

> **Divergence — `google/cluster`:** Required File Layout — `provider.tf` contains the data source `data.google_client_config.default`, which is used by both `kubeconfig.tf` and the kubernetes provider alias block in the same file; per the data source placement rule, a data source used by multiple resources belongs in `data_sources.tf`, not co-located with a provider block. Planned resolution: move the data source to `data_sources.tf` in the v1 release.

> **Divergence — `scaleway/cluster`:** Configuration Inheritance — `precondition` lifecycle blocks are absent from `scaleway_k8s_cluster` for required attributes (`region`, `cluster_version`), violating the rule that required attributes with no module default must be guarded by a precondition on the primary resource. Planned resolution: add preconditions in the v1 release.

> **Divergence — `scaleway/cluster/node-pool`:** Configuration Inheritance — `precondition` lifecycle blocks are absent from `scaleway_k8s_pool` for required attributes (`zones`, `node_type`, `min_size`, `max_size`), violating the rule that required attributes with no module default must be guarded by a precondition on the primary resource. Planned resolution: add preconditions in the v1 release.

> **Divergence — `scaleway/cluster`:** Networking — nodes are assigned public IPs by default (`public_ip_disabled` defaults to `false` in `node_pool.tf`), violating the rule that nodes MUST be configured with private IPs only by default. Planned resolution: flip the default to `true` in the v1 release.

> **Divergence — `scaleway/cluster/node-pool`:** Tagging and Labelling — the node-pool module exposes no configuration attribute for Kubernetes node labels; node labels can only be approximated by encoding them as Scaleway tag strings, with no guarantee that they are applied to the Kubernetes node object's `.metadata.labels`, violating the rule that node labels MUST be applied to both the cloud API and the Kubernetes node object. Planned resolution: add a dedicated node label attribute once the Scaleway provider exposes first-class Kubernetes node label support.

> **Divergence — `scaleway/cluster`:** Cluster API Authentication — `scaleway_k8s_cluster.current.kubeconfig[0].token` is a long-lived static admin token issued by the cluster resource; Scaleway does not expose a control to disable static credential issuance on the cluster resource, so this cannot currently be resolved, but it diverges from the rule that static long-lived credentials must be disabled where the provider exposes such a control. Planned resolution: revisit when the Scaleway provider exposes a control to disable static token issuance.

## Provider-Specific Exceptions

Exceptions are permanent, justified departures from the standard module contract. Unlike divergences, exceptions are not planned to be resolved — they exist because the standard rule cannot be applied to a specific module without breaking something fundamental (e.g. a circular dependency).

When adding an exception, update the `AGENTS.md` Critical Constraints to remind future agents that this file must be kept current.

When an exception becomes unnecessary (e.g. a refactor removes the underlying constraint), remove its entry from this file.

### Format

> **Exception — `<path/to/module>`:** `<variable or output name>` — `<one sentence explaining why the standard contract cannot be met>`.

### Entries

> **Exception — `aws/cluster/node-pool`:** `cluster_default_node_pool_name` and `cluster_default_node_pool_subnet_ids` — the node-pool module for extra node pools determines subnets from the default node pool's subnet IDs by default; when provisioning the default node pool itself these variables are required to break the circular dependency.

> **Exception — `azurerm/cluster`:** `provider.tf` — the AKS cluster module requires a `kubernetes` provider alias configured with static client certificate credentials from `kube_config`; because provider blocks cannot be placed in any of the standard required files, a dedicated `provider.tf` is the only viable location for this alias configuration.

> **Exception — `google/cluster`:** `provider.tf` — the GKE cluster module requires a `kubernetes` provider alias configured with a short-lived GCP access token obtained from `data.google_client_config.default`; because provider blocks cannot be placed in any of the standard required files, a dedicated `provider.tf` is the only viable location for this alias configuration.

> **Exception — `google/cluster`:** `cluster_role_binding.tf` — on GKE, a freshly-created cluster grants no Kubernetes RBAC permissions to any GCP IAM identity by default; the `kubernetes_cluster_role_binding` that grants `cluster-admin` to the currently-authenticated GCP service account (the CI/CD automation identity) is required to bootstrap RBAC so that the `kubernetes` and `kbst/kustomization` providers can operate against the cluster during the same Terraform run, directly supporting the Cluster API Authentication requirement.
