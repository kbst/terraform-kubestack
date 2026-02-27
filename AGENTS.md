# Kubestack AGENTS.md — Framework Development

> **This file governs framework development.**
> For framework _usage_, see the AGENTS.md included with each quickstart.

## Critical Constraints — Read First

These rules have no exceptions and MUST be applied before taking any other action:

- **NEVER** run `make test` or `make cleanup` unless the user explicitly instructs you to. These targets create and destroy real cloud infrastructure and incur real costs.
- **NEVER** run OpenTofu/Terraform commands (`tofu`, `terraform`) directly. Always use the Makefile targets.
- **ALWAYS** run `make validate` after making any change to module code or test configuration. It is safe to run at any time.
- **ALWAYS** update `tests/` when any module interface changes (new variables, removed variables, changed types).
- **ALWAYS** update the relevant quickstart examples when any module interface changes.
- **ALWAYS** update `DEVIATIONS.md` when adding a provider-specific exception or documenting a divergence between implementation and rules. See the Tracking Divergences and Exceptions section.

## Mandatory Update Obligations

Before considering any task complete, check each row of the table below and apply every obligation that matches what you changed.

| What changed | Obligations |
|---|---|
| Any module interface (variable added, removed, renamed, or type changed) | Update `tests/` to reflect the new interface. Update all affected quickstart examples. Run `make validate`. |
| `common/configuration` or `common/metadata` | Run the module's unit tests (`make validate` does not cover these). See the Unit Tests for Common Modules section. |
| Any module code or `tests/` configuration | Run `make validate`. |
| Any divergence between implementation and rules discovered or resolved | Add or remove the entry in `DEVIATIONS.md`. |
| Any permanent exception to the standard module contract added or removed | Add or remove the entry in `DEVIATIONS.md`. |
| New cloud provider added | Add provider-specific CLI build and dist targets to `oci/Dockerfile`, following the pattern of existing providers. Add auth instructions to the shared quickstart `README.md`. |
| New quickstart added | Symlink shared files (`README.md`, `.gitignore`, `.user/`) to `quickstart/src/configurations/_shared/` instead of duplicating them. |

## About Kubestack

Kubestack is an OpenTofu/Terraform framework for platform engineering teams building Kubernetes-based platforms. It provides re-usable modules to manage clusters, node pools, and platform services from a unified configuration using a GitOps workflow.

### Core Design Philosophy

These principles govern all design decisions. Keep them in mind when resolving ambiguities not covered by a specific rule:

- **Inheritance-based configuration** — all environments derive from a single base configuration, preventing drift.
- **Separated infrastructure and application environments** — infrastructure changes never block application deployments.
- **Shared-nothing architecture** — every environment has its own fully independent set of cluster and node pool resources. Nothing is shared between environments or across clusters.
- **Platform unification** — provider-specific managed clusters become a consistent platform by installing platform services via Kubestack platform service modules, delivering the same capabilities regardless of the underlying cloud provider.
- **GitOps workflow and automation** — proposed changes are previewed with `tofu plan` against any environment via pull request automation, then applied with `tofu apply` across environments in promotion order from least critical to most critical.

### Module Types

| Type | Purpose |
|---|---|
| **Cluster modules** | Provision a managed Kubernetes cluster from a cloud provider along with all required infrastructure (VPC, IAM, etc.). |
| **Node-pool modules** | Configure and manage node pools attached to a cluster. Live as a submodule inside the cluster module directory. |
| **Platform service modules** | Install cluster-level services that must exist before applications can be deployed. |

## Design Principles

All Kubestack modules MUST adhere to every principle in this section.

When a provider does not support a required behaviour (e.g. private nodes), apply the most restrictive option the provider does support, document the gap in a `# TODO:` comment directly above the relevant resource argument, and note it in the PR description.

### Configuration Inheritance

- All environments inherit their configuration from the base environment. The base environment key defaults to `apps` (set via `configuration_base_key`). An environment-specific value always overrides the inherited base value.
- The inheritance logic is implemented in the `common/configuration` module. All Kubestack modules MUST use it. See the Variables and Outputs section for the required usage pattern.
- Because all `configuration` object attributes must be marked `optional(...)` to support inheritance, values that have no module default and must always be user-provided (region, zones, instance type, and `min`/`max` node counts — see Multi-Zone Resilience and Node Pool Lifecycle sections) cannot be enforced by the type system alone. For each such attribute, modules MUST add a `lifecycle` `precondition` block on the primary resource (the cluster resource in a cluster module, the node-pool resource in a node-pool module). The condition MUST check that `local.cfg.<attribute_name>` is not `null`. The error message MUST name the attribute and state that it is required, e.g.: `"<attribute_name> must be set — Kubestack does not provide a default for this value."`.

### Multi-Zone Resilience

- Users MUST explicitly specify a region and availability zones for every cluster and node pool. Modules MUST NOT set any default for region or zones. Node pools MUST be placed in the same region as their cluster. Different node pools within the same environment MAY specify different zones independently. Users MAY specify different zones per environment for a node pool via its configuration inheritance mechanism.
- Node pool module implementations MUST distribute nodes across the specified zones.
- Load balancers MUST be distributed across the same zones as the nodes.

### Kubernetes Version Management

- Auto-update for **patch versions** MUST be enabled by default.
- Users specify the Kubernetes version using one of two mutually exclusive methods:
  1. **Explicit**: specify major and minor version (e.g., `1.30`).
  2. **Channel**: select a release channel (e.g., `STABLE`).
- If both an explicit version and a release channel are specified, the explicit version MUST take precedence.
- Users MAY configure a maintenance window where the provider supports it. When a Kubestack default is required, it MUST target 3:00 AM UTC.

### Node Pool Lifecycle

- **Self-healing** MUST be enabled by default. Users MAY disable it via configuration.
- **Instance type** (the provider-specific attribute for node size, e.g. `instance_type`, `vm_size`, `node_type`) MUST always be specified by the user. Modules MUST NOT set any default.
- **Auto-scaling** MUST be enabled by default. Users MAY disable it via configuration.
  - `min` and `max` node counts MUST always be specified by the user. Modules MUST NOT set any default for these values.
  - `current` / `desired` / `initial` node count (where the provider exposes it) MUST be owned by the autoscaler and MUST NOT be managed by OpenTofu/Terraform state. Implement this by adding a `lifecycle { ignore_changes }` block on the node-group or node-pool resource, targeting the provider's desired/initial count argument.

### Cloud Provider Isolation

- Provider-specific multi-region or multi-cloud features MUST be disabled.
- Kubestack assumes exactly **one region and cloud provider per cluster**. Multi-region or multi-cloud in Kubestack means creating multiple clusters from the same infrastructure-as-code repository.
- Cluster-level add-ons MUST be disabled by default, unless they are required to support another core design principle such as self-healing or auto-scaling. The preferred approach is to install platform services via Kubestack platform service modules, which allows platform builders to compose a consistent platform across cloud providers.
- Kubestack modules MAY expose opt-in configuration attributes to enable provider add-ons that are disabled by default. This allows users to enable them when needed without making them part of the opinionated baseline.

### Networking

- Every cluster module MUST create its own dedicated network resources (VPC, subnets, route tables, gateways, and any other provider-required constructs). Sharing or accepting externally-created network resources is NOT supported.
- All network resources for a cluster module MUST be placed in a file named `network.tf` inside that cluster module. This applies to all providers, regardless of provider-conventional naming (e.g. use `network.tf`, not `vpc.tf`).
- The CNI plugin MUST default to the provider's recommended option. Where the provider exposes a CNI choice, it MUST be user-configurable via a `cni` (or equivalent) configuration attribute.
- Network policies MUST be enabled by default where the provider or CNI supports enforcement at the cluster level. Users MAY disable them where the provider exposes that option.
- Nodes MUST be configured with private IPs only by default. Cluster egress MUST be routed through NAT gateways (or the provider-equivalent) so that nodes can reach the internet without being directly reachable from it. Users MAY opt out by enabling public IPs on nodes via configuration.
- The cluster control plane API endpoint MUST be publicly accessible by default, so that users can interact with the cluster without requiring VPN or private connectivity. Modules MUST expose a configuration option for users to restrict or fully privatise the API endpoint where the provider supports it.
- Modules MUST NOT implement any cloud provider-specific network connectivity features such as VPC peering or dedicated interconnects.
- Cross-cluster and external connectivity SHOULD be implemented by installing a service mesh via a Kubestack platform service module, preferring a provider-independent solution over provider-proprietary options.

#### CIDR Defaults

- Where a provider accepts CIDR arguments but does not require them, modules MUST NOT set values — pass `null` so the provider applies its own defaults.
- Where a provider requires explicit CIDR values, modules MUST use the defaults from that provider's official documentation.
- Users MAY override any CIDR via configuration to integrate with existing infrastructure.

### Identity and Access

#### Cluster API Authentication (Terraform and CI/CD)

- The `kubeconfig` output MUST be constructed from the host and credentials returned directly by the cluster resource. These credentials are valid for the duration of the Terraform run and are used by any Terraform provider that configures itself from the kubeconfig output (e.g. the `kbst/kustomization` or `kubernetes` provider). No additional credential exchange or IAM assumption step is performed by the module itself — CI/CD pipelines are expected to handle role assumption or workload identity federation before invoking Terraform.
- Where a provider exposes a control to disable static local accounts or long-lived credential issuance on the cluster resource (e.g. `local_account_disabled` on AKS, `issue_client_certificate = false` on GKE), that control MUST be set to disable static credentials.

#### Human User Authentication

- Kubestack modules do not manage human user kubeconfigs. Human users authenticate by running the cloud provider's CLI to obtain a kubeconfig via IAM. Whether this IAM authentication approach is used only for admin break-glass access or for all platform users is a decision for the platform builder.
- Modules MUST NOT provision any cluster-level RBAC bindings for named human users. User identity and RBAC are the responsibility of platform service modules or the platform operator.
- For platform builders who want to unify end-user authentication across providers behind a single IdP, installing an authentication proxy (e.g. TremoloSecurity/kube-oidc-proxy, vmware/pinniped) as a Kubestack platform service module is the recommended approach. This is optional and at the platform builder's discretion.

#### Workload Identity

- Workload identity federation (OpenID Connect tokens for workload service accounts) MUST be enabled by default on all providers. Users MAY disable it via configuration.

### Tagging and Labelling

- All cloud and Kubernetes resources MUST be tagged/labelled using the output from the `common/metadata` module.
- Users MUST be able to add extra labels/tags to all cloud and Kubernetes resources via a configuration attribute whose name mirrors the upstream provider resource argument (e.g. `tags` for AWS and Azure, `resource_labels` for GKE cluster resources). When merging, the following precedence applies, from lowest to highest:
  1. Kubestack metadata labels (from `common/metadata`).
  2. User-supplied labels — user values take precedence over metadata labels on key collision.
  3. Mandatory provider labels (e.g. the EKS `kubernetes.io/cluster/<name>=shared` tag) — always applied last and MUST NOT be suppressible by user configuration.

#### Node Labels

Node-pool modules MUST additionally expose a configuration attribute for Kubernetes node labels whose name mirrors the upstream provider resource argument (e.g. `labels` for GKE and EKS, `node_labels` for AKS). Labels specified via this attribute MUST be applied to both the cloud API (the node/instance resource) and the Kubernetes API (the node object's `.metadata.labels`) for every node in the pool.

- This node-label attribute MUST be passed through from the cluster module's default node pool configuration to the node-pool submodule call in `node_pool.tf`, so that the default node pool is configurable in the same way as any additional node pool.
- The full precedence order on node resources is: metadata labels → user-supplied cloud resource labels → user-supplied node labels → mandatory provider labels.

### Node Taints

- Users MUST be able to specify node taints on both the default node pool and any additional node pools matching the provider specific attribute name and variable type/format.

### Cross-Provider Developer Experience

- Region, zones, instance type, and `min`/`max` node counts MUST be exposed as required configuration attributes in every module, using provider-specific attribute names. Modules MUST NOT set defaults for these values.
- All configuration attribute names SHOULD mirror the respective provider resource attribute names.
- Provider resource blocks containing nested arguments SHOULD be reflected as nested configuration object attributes.

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

Every module MUST use the following file layout. Do NOT consolidate these files or add content to a file that does not match its stated purpose.

| File | Required In | Purpose |
|---|---|---|
| `main.tf` | All modules | Configuration module call, metadata module call, and the module's primary resource (cluster or node-pool resource). |
| `variables.tf` | All modules | All input variable definitions. |
| `outputs.tf` | All modules | All output definitions. |
| `moved.tf` | All modules | All `moved` blocks. No other content. |
| `versions.tf` | All modules | Provider requirements and minimum OpenTofu/Terraform version constraint. |
| `network.tf` | Cluster modules | All network resources (VPC, subnets, route tables, gateways, and any other provider-required network constructs). |
| `kubeconfig.tf` | Cluster modules | Kubeconfig local value. See Kubeconfig Generation section. |
| `ingress.tf` | Cluster modules | Default ingress feature resources. |
| `node_pool.tf` | Cluster modules | Default node pool call (see Default Node Pool Decision Tree below for exceptions). |
| `data_sources.tf` | When required | Data sources shared across resources or containing conditional logic (see rule below). |

**Data source placement rule:**

- A data source used by **exactly one resource** → place it directly before that resource in the same file.
- A data source used by **multiple resources** OR containing **conditional logic** → place it in `data_sources.tf`.

**Additional files** (e.g., `roles.tf`, `launch_template.tf`) MAY be created when grouping resources into a dedicated file meaningfully improves readability.

**`moved` block rule:**

When a resource is renamed or moved, add a `moved` block to `moved.tf`. MUST NOT run `tofu state mv` (or `terraform state mv`) — Kubestack releases modules, not managed infrastructure, so any state operation would only affect `tests/` and would not be portable to downstream module users who manage their own state.

If a rename or move cannot be expressed as a declarative `moved` block, it is a breaking change. Past the v1 release, breaking changes MUST be avoided. When a pre-v1 breaking change is unavoidable, document the required manual `tofu state mv` command as an explicit migration step in the release notes.

`moved.tf` MUST contain only `moved` blocks — no resources, data sources, or locals.

### Default Node Pool — Decision Tree

Every cluster MUST have a default node pool. Determine the implementation approach by applying the following rules in order:

1. **Provider mandates a built-in default node pool that cannot be disabled** (e.g., AKS / `azurerm`):
   → Use the provider's built-in default node pool. `node_pool.tf` is NOT required.

2. **Provider includes a default node pool that CAN be disabled** (e.g., GKE / `google`):
   → Disable the provider's built-in default node pool AND provision the default node pool by calling the cluster's node-pool submodule in `node_pool.tf`.

3. **All other providers** (e.g., EKS / `aws`):
   → Provision the default node pool by calling the cluster's node-pool submodule in `node_pool.tf`.

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
  default  = "apps"                 # optional for module users; MUST be defined in all modules
  nullable = false
}
```

Rules for the `configuration` object type:

- ALL attributes MUST be marked `optional(...)`.
- Attributes MUST NOT specify a default value inside the `optional()` call. The inheritance implementation in `common/configuration` determines whether to inherit or override a value by checking whether the attribute is `null`. Adding defaults inside `optional()` breaks this check.

### Using Configuration Inside a Module

Inside every module, apply the following pattern exactly:

**Step 1.** Call the `common/configuration` module in `main.tf`:

```hcl
module "configuration" {
  source        = "../../common/configuration"
  configuration = var.configuration
  base_key      = var.configuration_base_key
}
```

**Step 2.** Expose the merged result as `local.cfg` in the same `main.tf`:

```hcl
locals {
  cfg = module.configuration.merged[terraform.workspace]
}
```

**Step 3.** Reference `local.cfg.<attribute>` everywhere a resource needs a configuration value. Never reference `var.configuration` directly in resource arguments.

### Setting Resource Argument Values

Kubestack prefers upstream provider defaults. Apply the following rules when assigning `local.cfg` values to resource arguments:

| Situation | Pattern |
|---|---|
| No Kubestack-level default is needed | `argument = local.cfg.some_attribute` |
| A Kubestack-level default is required | `argument = try(coalesce(local.cfg.some_attribute, null), <default>)` |

**How `try(coalesce(local.cfg.<attr>, null), <default>)` works:**

- `coalesce(local.cfg.<attr>, null)` returns the configured value when set, or `null` when the attribute was not configured.
- `try(..., <default>)` catches both nested-key access errors and the `null` from `coalesce`, falling through to the Kubestack default.
- This ensures the default value is specified in exactly one place — never inside `optional()` in `variables.tf`.

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

The authentication field inside `users[].user` is provider-specific:

- Use `token` for providers that issue short-lived tokens (e.g. EKS, GKE).
- Use `client-certificate-data` / `client-key-data` for providers that issue client certificates (e.g. AKS).

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

Do NOT add extra variables or outputs without a compelling reason. When an exception is necessary, record it in `DEVIATIONS.md` following the instructions in the Tracking Divergences and Exceptions section below.

### Tracking Divergences and Exceptions

All known gaps between the rules in this file and the current implementation, and all permanent justified exceptions to the standard module contract, are tracked in `DEVIATIONS.md`. Keep that file current — do not leave divergences or exceptions undocumented.

**Divergences** are temporary: places where the implementation does not yet comply with a rule, with a planned resolution. Add a divergence entry when you discover or introduce such a gap. Remove the entry once it is resolved.

**Exceptions** are permanent: justified deviations from the standard contract that cannot be resolved without breaking something fundamental (e.g. a circular dependency). Add an exception entry when a module must deviate from the standard variable or output contract. Remove the entry only if a refactor makes it unnecessary.

For the entry formats and all current entries, see `DEVIATIONS.md`.

## Testing

See Critical Constraints at the top of this file for the safety rules that govern all test-related commands. The rules in this section cover how and when to run tests.

### Validation — Run After Every Change

Run after every change to module code or `tests/` configuration:

```
make validate
```

This target is always safe to run. A task is not complete until `make validate` passes.

### Unit Tests for Common Modules

`make validate` does not cover the `common/` modules. After any change to `common/configuration` or `common/metadata`, run the affected module's unit tests directly:

```
make -C common/configuration test
make -C common/metadata test
```

### Integration Test Configuration

- The multi-cloud test platform configuration lives in `tests/`.
- When any module interface changes (added/removed/renamed variables, changed types), update `tests/` to reflect the new interface before running `make validate`.

## Dist Assets

The Kubestack framework is released as three asset types. Refer to the Mandatory Update Obligations section at the top of this file for a complete list of when each asset must be updated.

| Asset | Description |
|---|---|
| **Versioned modules** | Consumed via `module` blocks using GitHub URLs. |
| **Container image** | Base image for CI/CD pipelines and manual tasks, bundling cloud provider CLIs for IAM authentication and debugging, and Kustomize, OpenTofu/Terraform binaries at the correct version (`oci/Dockerfile`). |
| **Quickstarts** | Example directory layouts for bootstrapping new user repositories. Quickstart examples MUST include `name_prefix`, `base_domain`, region, zones, instance type, and autoscaling `min`/`max` — all values that have no module default and must always be user-provided. Leave all other values absent to rely on module and provider defaults. Common files (`README.md`, `.gitignore`, `.user/`) are shared via symlinks pointing to `quickstart/src/configurations/_shared/`. |
