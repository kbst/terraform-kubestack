# Kubestack AGENTS.md — Framework Development

> **This file governs framework development.**
> For framework _usage_, see the AGENTS.md included with each quickstart.

---

## Critical Constraints — Read First

These rules have no exceptions and MUST be applied before taking any other action:

- **NEVER** run `make test` or `make cleanup` unless the user explicitly instructs you to. These targets create and destroy real cloud infrastructure and incur real costs.
- **NEVER** run OpenTofu/Terraform commands (`tofu`, `terraform`) directly. Always use the Makefile targets.
- **ALWAYS** run `make validate` after making any change to module code or test configuration. It is safe to run at any time.
- **ALWAYS** update `tests/` when any module interface changes (new variables, removed variables, changed types).
- **ALWAYS** update the relevant quickstart examples when any module interface changes.

---

## About Kubestack

Kubestack is an OpenTofu/Terraform framework for platform engineering teams building Kubernetes-based platforms. It provides re-usable modules to manage clusters, node pools, and platform services from a unified configuration using a GitOps workflow.

### Module Types

| Type | Purpose |
|---|---|
| **Cluster modules** | Provision managed Kubernetes offerings from cloud providers along with all required infrastructure (VPC, IAM, etc.) |
| **Node-pool modules** | Configure and manage node pools attached to a cluster |
| **Platform service modules** | Install cluster-level services that must exist before applications can be deployed |

### Core Design Philosophy

- **Inheritance-based configuration** prevents drift between environments by deriving all environments from a single base configuration.
- **Separated infrastructure and application environments** prevent infrastructure changes from blocking application deployments.

---

## Design Principles

All Kubestack modules MUST adhere to every principle in this section.

### Configuration Inheritance

- All environments inherit their configuration from the base environment. The base environment key defaults to `apps` (set via `configuration_base_key`). An environment-specific value always overrides the inherited base value. The inheritance is implemented in the `common/configuration` module, which all Kubestack modules MUST use.

### Multi-Zone Resilience

- Node pools MUST be distributed across a minimum of three availability zones by default. The user MUST explicitly specify the zones and MAY specify fewer than three.
- Load balancers MUST be distributed across the same zones as the nodes.

### Kubernetes Version Management

- Auto-update for **patch versions** MUST be enabled by default.
- Users specify the Kubernetes version using one of two mutually exclusive methods:
  1. **Explicit**: specify major and minor version (e.g., `1.30`).
  2. **Channel**: select a release channel (e.g., `STABLE`).
- If both an explicit version and a release channel are specified, the explicit version MUST take precedence.
- Users MAY configure a maintenance window if the provider support it. When a default is required, it SHOULD target 3:00 AM UTC.

### Node Pool Lifecycle

- **Self-healing** MUST be enabled by default. Users MAY disable it via configuration.
- **Auto-scaling** MUST be enabled by default. Users MAY disable it via configuration.
  - `min` and `max` node counts MUST always be user-configurable. The default `min` SHOULD be one per zone and the default `max` SHOULD be two times `min`.
  - `current` / `desired` / `initial` node count (where the provider exposes it) MUST be owned by the autoscaler and MUST NOT be managed by OpenTofu/Terraform state. Implement this by adding a `lifecycle { ignore_changes }` block on the node-group or node-pool resource, targeting the provider's desired/initial count argument.

### Cloud Provider Isolation

- Provider-specific multi-region or multi-cloud features MUST be disabled.
- Kubestack assumes exactly **one cluster per region per cloud provider**.

### Networking

- Every cluster module MUST create its own dedicated network resources (VPC, subnets, route tables, gateways, and any other provider-required constructs). Sharing or accepting externally-created network resources is NOT supported. Place all network resources in a dedicated `network.tf` file inside the cluster module.
- The CNI plugin defaults to the provider's recommended option. Where the provider exposes a CNI choice, it MUST be user-configurable via a `cni` (or equivalent) configuration attribute.
- Network policies MUST be enabled by default where the provider or CNI supports enforcement at the cluster level. Users MAY disable them where the provider exposes that option.
- The Kubestack-preferred approach for cross-cluster and external connectivity is installing a service mesh via a platform service module. A provider-independent solution is preferred over provider-proprietary options.

#### CIDR Defaults

Kubestack defers to the upstream defaults of each cloud provider. Where a provider accepts CIDR arguments but does not require them, MUST NOT set values — pass `null` so the provider applies its own defaults. Where a provider requires explicit CIDR values to be set, use the defaults from that provider's official documentation. Users MAY override any CIDR via configuration to integrate with existing infrastructure.

### Identity and Access

- Support for OpenID Connect (OIDC) tokens for a workload's service account MUST be enabled by default. Users MAY disable it via configuration.

### Tagging and Labelling

- All cloud and Kubernetes resources MUST be tagged/labelled using the output from the `common/metadata` module.
- Users MUST be able to add extra tags/labels for cloud resources and Kubernetes resources **independently** via separate configuration attributes.

### Node Taints

- Users MUST be able to specify node taints on both the default node pool and any additional node pools.

### Cross-Provider Developer Experience

- Key configuration (zones, min/max node counts, instance types) MUST be available for any module, using provider-specific variable names.
- All configuration attribute names SHOULD mirror the respective provider resource attribute names.
- Provider resource blocks containing nested arguments SHOULD be reflected as nested configuration object attributes.

---

## Repository and Module Layout

### Directory Structure

```
<repo-root>/
  common/              # Modules shared across all cloud providers
  <provider>/          # Provider-specific modules; directory name = TF provider name (aws, azurerm, google, scaleway, …)
    cluster/           # Cluster module
      node-pool/       # Node-pool submodule
```

### Required Files

Every module MUST use the following file layout. Do not consolidate these files.

| File | Required In | Purpose |
|---|---|---|
| `main.tf` | All modules | Configuration module call, metadata module call, and the module's primary resource (cluster or node-pool resource). |
| `variables.tf` | All modules | All input variable definitions. |
| `outputs.tf` | All modules | All output definitions. |
| `moved.tf` | All modules | All `moved` blocks. No other content. |
| `versions.tf` | All modules | Provider requirements and minimum OpenTofu/Terraform version constraint. |
| `kubeconfig.tf` | Cluster modules | Kubeconfig local value. See kubeconfig rules below. |
| `ingress.tf` | Cluster modules | Default ingress feature resources. |
| `node_pool.tf` | Cluster modules | Default node pool (see decision tree below for exceptions). |
| `data_sources.tf` | When required | Data sources shared across resources or containing conditional logic (see rule below). |

**Data source placement rule:**

- A data source used by **exactly one resource** → place it directly before that resource in the same file.
- A data source used by **multiple resources** OR containing **conditional logic** → place it in `data_sources.tf`.

**Additional files** (e.g., `vpc.tf`, `roles.tf`, `launch_template.tf`, `network.tf`) MAY be created when grouping resources into a dedicated file meaningfully improves readability.

### Default Node Pool — Decision Tree

Every cluster MUST have a default node pool. Determine the implementation approach by applying the following rules in order:

1. **Provider mandates a built-in default node pool that cannot be disabled** (e.g., AKS / `azurerm`):
   → Use the provider's built-in default node pool. `node_pool.tf` is NOT required.

2. **Provider includes a default node pool that CAN be disabled** (e.g., GKE / `google`):
   → Disable the provider's built-in default node pool AND provision the default node pool by calling the cluster's node-pool submodule in `node_pool.tf`.

3. **All other providers** (e.g., EKS / `aws`):
   → Provision the default node pool by calling the cluster's node-pool submodule in `node_pool.tf`.

---

## Variables and Outputs

### Configuration Inheritance Variables (All Module Types)

Every Kubestack module MUST define both of the following variables exactly as shown:

```hcl
variable "configuration" {
  type     = map(object({ ... }))   # map key = environment name (workspace)
  nullable = false
}

variable "configuration_base_key" {
  type     = string
  default  = "apps"                 # optional for module users; but MUST be defined in all modules
  nullable = false
}
```

Rules for the `configuration` object type:

- ALL attributes MUST be marked `optional(...)`.
- Attributes MUST NOT specify a default value inside the `optional()` call. The inheritance implementation in `common/configuration` determines whether to inherit or override a value by checking whether the attribute is `null`. Adding defaults inside `optional()` breaks this check.

### Using Configuration Inside a Module

Inside every module, apply the following pattern:

1. Call the `common/configuration` module in `main.tf`, passing `var.configuration` as `configuration` and `var.configuration_base_key` as `base_key`.
2. Expose the merged result as `local.cfg`, keyed on `terraform.workspace`.
3. Reference `local.cfg.<attribute>` everywhere a resource needs a configuration value.

```hcl
module "configuration" {
  source        = "../../common/configuration"
  configuration = var.configuration
  base_key      = var.configuration_base_key
}

locals {
  cfg = module.configuration.merged[terraform.workspace]
}
```

### Setting Resource Argument Values

Kubestack prefers upstream provider defaults. Apply the following rules when assigning `local.cfg` values to resource arguments:

| Situation | Pattern |
|---|---|
| No Kubestack-level default is needed | Pass `null` directly: `argument = local.cfg.some_attribute` |
| A Kubestack-level default is required | `argument = try(coalesce(local.cfg.some_attribute, null), <default>)` |

**Explanation of `try(coalesce(local.cfg.<attr>, null), <default>)`:**

- `coalesce(local.cfg.<attr>, null)` returns the configured value if set, or `null` if the attribute was not configured.
- `try(..., <default>)` catches both nested-key errors and the `null` from `coalesce`, falling through to the default. This ensures the default value is specified in exactly one place.

**Example** (from `aws/cluster/main.tf`):

```hcl
endpoint_private_access = try(coalesce(local.cfg.cluster_endpoint_private_access, null), false)
endpoint_public_access  = try(coalesce(local.cfg.cluster_endpoint_public_access, null), true)
```

### Cluster Module Outputs

Cluster modules MUST define exactly the following outputs. Do NOT add extra outputs without a compelling, provider-specific reason — inconsistent outputs across providers degrade the cross-provider user experience.

| Output | Value | Notes |
|---|---|---|
| `cluster` | The full cluster resource object | All attributes the cluster resource returns. |
| `current_config` | `local.cfg` | The merged configuration for the active workspace. |
| `current_metadata` | The full metadata module output | The entire `module.cluster_metadata` output. |
| `kubeconfig` | YAML-encoded kubeconfig | Mark as `sensitive = true`. |

### Kubeconfig Generation

The kubeconfig MUST be constructed as a `local` value (not stored as a resource) inside `kubeconfig.tf`, using `yamlencode()`. It MUST follow the standard Kubernetes kubeconfig structure:

```hcl
locals {
  kubeconfig = yamlencode({
    apiVersion = "v1"
    kind       = "Config"
    clusters = [{
      cluster = {
        server                     = "<cluster endpoint>"
        certificate-authority-data = "<base64-encoded CA certificate>"
      }
      name = "<cluster name>"
    }]
    users = [{
      user = { token = "<authentication token>" }   # or client-certificate-data / client-key-data
      name = "<cluster name>"
    }]
    contexts = [{
      context = {
        cluster = "<cluster name>"
        user    = "<cluster name>"
      }
      name = "<cluster name>"
    }]
    current-context = "<cluster name>"
    preferences     = {}
  })
}
```

The authentication field inside `users[].user` is provider-specific: use a `token` for providers that issue short-lived tokens (like EKS, GKE), or `client-certificate-data` / `client-key-data` for providers that issue client certificates (like AKS).

### Node-Pool Module Variables and Outputs

Node-pool modules MUST define `configuration` and `configuration_base_key` as described above, PLUS the following additional variables:

| Variable | Type | Source |
|---|---|---|
| `cluster` | `any` | The `cluster` output from the corresponding cluster module. |
| `cluster_metadata` | `any` | The `current_metadata` output from the corresponding cluster module. |

Node-pool modules MUST define the following output:

| Output | Value | Notes |
|---|---|---|
| `current_config` | `local.cfg` | The merged configuration for the active workspace. |

Do NOT add extra variables or outputs without a compelling reason.

> **Documented exception:** `aws/cluster/node-pool` defines two additional provider-specific variables — `cluster_default_node_pool_name` and `cluster_default_node_pool_subnet_ids` — because the node-pool module for extra node pools determines subnets from the default node pool's subnet IDs by default. When provisioning the default node pool itself, however, these variables are necessary to break the circular dependency.

---

## Testing

### Safety Rules

> **NEVER run `make test` or `make cleanup` unless the user explicitly instructs you to.**
> **NEVER run OpenTofu/Terraform commands directly.** Always use the Makefile targets.

These tests provision and destroy real cloud infrastructure across multiple providers and incur real costs.

### Validation — Run After Every Change

```
make validate
```

This target is safe to run at any time. It MUST be run to confirm that all changes are syntactically and structurally valid before considering a task complete.

### Unit Tests for Common Modules

After making any change to `common/configuration` or `common/metadata`, run the module's unit tests:

```
cd common/configuration && tofu test
cd common/metadata      && tofu test
```

### Integration Test Configuration

- The multi-cloud test platform configuration lives in `tests/`.
- When any module interface changes (added/removed/renamed variables, changed types), `tests/` MUST be updated to reflect the new interface before running `make validate`.

---

## Dist Assets

The Kubestack framework is released as three asset types. When making changes, apply the corresponding update obligations:

| Asset | Description | Update Obligation |
|---|---|---|
| **Versioned modules** | Consumed via `module` blocks using GitHub URLs | Update `tests/` and quickstarts to reflect interface changes. |
| **Container image** | Base image for CI/CD pipelines and manual tasks (`oci/Dockerfile`) | When adding a new cloud provider, add provider-specific CLI build and dist targets to `oci/Dockerfile`, following the pattern of existing providers. |
| **Quickstarts** | Example directory layouts for bootstrapping new repositories | MUST be updated to reflect any module interface or usage changes. Common files (`README.md`, `.gitignore`, `.user/`) are shared via symlinks pointing to `quickstart/src/configurations/_shared/`. When adding a new quickstart, symlink these files instead of duplicating them. When adding a new provider, add its auth instructions to the shared `README.md`. |
