# Kubestack AGENTS.md — Framework Usage

> This file governs using the Kubestack framework to define and manage Kubernetes platform infrastructure.
> For contributing to the framework itself, see the `AGENTS.md` in the framework repository root.

---

## Start Here

**Before doing anything else, read the Platform section of `README.md`.**
Every value already recorded there must be used as-is — never ask the user for a value that is already recorded.
If a required value is missing, ask the user, record the answer in `README.md`, then write the files.

---

## Constraints

These rules are absolute. They apply to every task without exception.

### Commands you must never run

- `terraform apply` / `tofu apply`
- `terraform destroy` / `tofu destroy`
- `terraform init` / `tofu init`
- `terraform plan` / `tofu plan`
- Any `git` command that's not read-only — no commits, pushes, branch creation, or tagging

These commands make irreversible changes to live infrastructure or the repository state. They must always be run by a human who has reviewed what will happen. If the user asks you to run any of them, explain that you cannot do so and give them the exact command to run themselves.

### The one command you must run

After writing or editing any `.tf` file, run `tofu validate` (or `terraform validate`) to verify syntax. This command is safe — it makes no cloud API calls and changes nothing.

### Other hard rules

- Never modify `.terraform.lock.hcl` by hand.
- Never hardcode secrets, credentials, keys, or certificates in any `.tf` file.
- Never edit `modules/<feature_name>/manifests/upstream.yaml` directly for Helm-based features. It is a generated file. To change what is rendered, edit `values.yaml` and re-run the `helm template` command recorded in `modules/<feature_name>/README.md` to regenerate it.
- Always update the Platform section of `README.md` after any task that adds, changes, or removes a platform component or setting.
- Always give the user the GitOps follow-up instructions at the end of every task. See [After every task](#after-every-task).

---

## Update Obligations

Before considering any task complete, apply every obligation from this table that matches what was done.

| What was done | Obligation |
|---|---|
| First-time repository scaffold | Fill in the Configuration table in `README.md` (framework version, environment names, base environment, `base_domain`). Add the first cluster to the Clusters table. |
| New cluster scaffolded (Stage 1) | Add a row to the Clusters table in `README.md`. Give the user the GitOps follow-up instructions and remind them that node pools and platform features must be added in separate subsequent stages. |
| Cluster removed | Remove its row from the Clusters table in `README.md`. Remove all its node pool and feature rows too. |
| New node pool scaffolded | Add a row to the Node Pools table in `README.md`. |
| Node pool removed | Remove its row from the Node Pools table in `README.md`. |
| New platform feature scaffolded | Add a row to the Platform Features table in `README.md`. |
| Platform feature removed | Remove its row from the Platform Features table in `README.md`. |
| Framework version changed | Update the framework version in the Configuration table in `README.md`. Update the `?ref=` value in every `source` reference to a Kubestack framework module across the entire repository. Update the Kubestack image tag in `Dockerfile` to the same version. |
| Environment added | Add the new environment name to the Configuration table in `README.md`. Add the new key to the `configuration` map in every module in the repository. |
| Environment removed | **Destructive.** Do not make any file changes immediately. Follow the staged process in [Removing an environment](#removing-an-environment). |
| Environment renamed | **Destructive.** Do not make any file changes immediately. Follow the staged process in [Renaming an environment](#renaming-an-environment). |
| Any task completed | Give the user the full GitOps follow-up instructions from [After every task](#after-every-task). |

When updating `README.md`: replace existing values. Never append duplicates or leave stale entries alongside new ones.

---

## Framework Version

The Kubestack framework version governs all release assets in the repository. These must always be identical — upstream releases bundle modules and the OCI image together so that all assets stay aligned:

- The `?ref=<version>` parameter in every Kubestack framework module `source` reference
- The container image tag in `Dockerfile`

Read the current version from the Configuration table in `README.md`.
When adding any new module to an existing repository, always match the version already in use.
When initialising a brand-new repository or updating the framework version, fetch the latest version from: https://www.kubestack.com/cli.json

All framework module sources follow the same GitHub format:

```
# cluster module
source = "github.com/kbst/terraform-kubestack//aws/cluster?ref=v0.18.1-beta.0"

# node-pool module
source = "github.com/kbst/terraform-kubestack//aws/cluster/node-pool?ref=v0.18.1-beta.0"

# platform feature module
source = "github.com/kbst/terraform-kubestack//kustomization/overlay?ref=v0.18.1-beta.0"
```

### After a framework version update

Upstream releases may also update required provider versions. After changing any `?ref=` or `Dockerfile` image tag, remind the user to run the following before committing:

```
tofu init -upgrade
```

This refreshes `.terraform.lock.hcl` to lock the provider versions required by the new release. The updated lock file must be included in the same commit as the version change.

---

## About Kubestack

Kubestack is an OpenTofu/Terraform framework for platform engineering teams. It provides:

- **Cluster modules** — provision a managed Kubernetes cluster (EKS on AWS, GKE on Google Cloud, AKS on Azure, Kapsule on Scaleway) and all required cloud infrastructure (VPC, IAM, subnets, etc.).
- **Node-pool modules** — add extra node pools to an existing cluster.
- **Platform feature modules** — deploy Kubernetes resources to a cluster (nginx ingress, Prometheus, cert-manager, etc.).

All modules implement a shared configuration inheritance model so that all environments derive from a single base configuration, preventing drift.

### Core concepts

- **Environments = Terraform workspaces.** Each environment (e.g. `ops`, `apps`) is a completely independent copy of the entire platform in the cloud. Nothing is shared between environments.
- **Inheritance.** The `apps` environment (or whichever key is set as `configuration_base_key`) is the base. All other environments inherit every attribute from the base and may override individual values. It is not possible to unset an inherited value by setting it to `null`.
- **Cluster naming.** Cluster module names follow the pattern `<provider>_<name_prefix>_<region>`, e.g. `eks_gc0_eu-west-1`. This name is used for the Terraform module identifier, the file prefix, and the provider aliases.
- **File-per-cluster convention.** Each cluster has its own `<cluster_name>_cluster.tf` and `<cluster_name>_providers.tf`. Node-pool and feature files are prefixed with the cluster name.

---

## Naming Rules

This section covers decisions that may not yet be recorded. Once a decision is made, record it in `README.md` and read it from there on every subsequent task — never re-derive it.

### Environment names

The default environment names are `ops` (internal, validates changes first) and `apps` (external, runs user workloads). These become Terraform workspace names.

| Pattern | When to use |
|---|---|
| `ops`, `apps` | Default. All application environments (dev, stage, prod) run inside the single `apps` infrastructure environment. |
| `ops`, `apps`, `apps-prod` | When non-prod and prod application workloads need blast-radius isolation at the infrastructure level. |

Environment names must be consistent across every module in the repository.
When using three environments, set `configuration_base_key = "apps-prod"` so that `apps` and `ops` both inherit from the production baseline.
Keys in the `configuration` map must be ordered from most critical to least critical (e.g. `apps-prod`, then `apps`, then `ops`); see [Configuration Inheritance](#configuration-inheritance).

**Choosing the right separation mechanism:**

| Goal | Use |
|---|---|
| Separate non-prod and prod workloads | Node pools (low overhead) or a third environment (maximum blast-radius protection). Not clusters. |
| Separate tenants or workload types | Node pools (low overhead) or additional clusters (maximum blast-radius protection). Not environments. |

### Changing environments on an existing platform

Environment names are recorded once at platform initialisation. Changing them on a running platform is not a routine operation. The right approach depends on what kind of change is being made.

**Adding an environment** is the least disruptive change. It provisions a new independent copy of the entire platform in the cloud. Existing environments are unaffected. Add the new key to the `configuration` map in every module and update the Configuration table in `README.md`.

For removing or renaming an environment, follow the staged processes below. These are multi-stage operations spanning weeks or months — not single commits. Your role at each stage is to prepare the code changes for that stage only, then hand off to the user with the GitOps follow-up instructions and explicit guidance on what must happen operationally before the next stage can begin.

### Removing an environment

Removing an environment destroys every resource in it — all clusters, node pools, and platform features it contains. Any application relying on that infrastructure loses it permanently. Before making any file changes, explain this to the user and ask for explicit confirmation that they want to proceed.

Once confirmed, the removal follows three stages:

**Stage 1 — Announce deprecation.**
Your work for this stage is to help the user communicate clearly to all teams using the environment that it will be shut down, giving them enough time to migrate their workloads elsewhere. You cannot send announcements, but you can help draft the message. No file changes are made in this stage. The stage is complete when the user confirms that the deprecation period has ended and all teams have migrated.

**Stage 2 — Remove platform features and node pools.**
Follow the same staged process as [Removing a Cluster](#removing-a-cluster): first remove all platform features across every cluster in the environment (Stage 1 of that process), then remove all additional node pools (Stage 2). Each is its own GitOps cycle. Your work ends after preparing the file changes for whichever of these sub-stages the user is performing — hand off and wait for confirmation before proceeding.

**Stage 3 — Remove the environment key.**
Remove the environment's key from the `configuration` map in every module across the entire repository. Remove the environment from the Configuration table in `README.md`. Your work ends there — do not run any git or terraform commands. Give the user the GitOps follow-up instructions with a clear warning that the Terraform plan will show all remaining infrastructure in that environment being destroyed. This is the expected signal for the reviewer to approve.

### Renaming an environment

There is no in-place rename. Terraform workspaces are identified by name; renaming one means provisioning all resources from scratch under the new name and then destroying all resources under the old name. Applications will need to migrate between the two environments while both are running in parallel.

Before making any file changes, explain this to the user — including that the process spans multiple weeks or months and requires applications to actively migrate — and ask for explicit confirmation that they want to proceed.

Once confirmed, the rename follows three stages:

**Stage 1 — Add the new environment.**
Add the new environment key to the `configuration` map in every module and update the Configuration table in `README.md`. Follow the "Environment added" obligation. Hand off to the user with the GitOps follow-up instructions. The new environment will be provisioned from scratch when the pipeline runs. The old environment continues to run unchanged — applications are not yet affected. The stage is complete when the user confirms the new environment is healthy and teams are ready to begin migrating.

**Stage 2 — Migrate applications.**
You cannot perform application migration, but remind the user that all teams must move their workloads from the old environment to the new one before the old environment can be removed. No file changes are made in this stage. The stage is complete when the user confirms that all applications have migrated and the old environment is no longer in use.

**Stage 3 — Remove the old environment.**
Follow all three stages of [Removing an environment](#removing-an-environment), starting from Stage 2 (the deprecation announcement was effectively the migration period in Stage 2 above). Hand off after each sub-stage and wait for confirmation before proceeding.

### `name_prefix`

A short label identifying the cluster's purpose, tenant, or compute type. It becomes part of the cluster name:

```
<name_prefix>-<workspace>-<region>
e.g. gc0-apps-eu-west-1
```

The numeric suffix makes the prefix a stable, incrementable identity:
- `gc0` — first general-compute cluster. Add `gc1` when `gc0` approaches capacity, before decommissioning `gc0`.
- `ml0` — first machine-learning cluster.
- `data0`, `platform0` — departmental or workload-type clusters.

When adding a new cluster, derive the `name_prefix` from the discovery questions in [Adding a Cluster](#adding-a-cluster):
- Same cloud, same region, same purpose → increment the counter on the existing prefix (e.g. `gc0` → `gc1`).
- Same cloud, same region, different purpose → introduce a new prefix that reflects the new purpose (e.g. `ml0`).
- New region or new cloud, same purpose → reuse the same prefix as the equivalent cluster in the other region or cloud (e.g. `gc0` again — the region in the cluster identifier already distinguishes it).

### `base_domain`

The domain suffix used to construct the FQDN for each cluster:

```
<cluster_name>.<provider_short>.<base_domain>
e.g. gc0-apps-eu-west-1.aws.infra.example.com
```

The user must own and control this domain. It is used for DNS and TLS configuration by platform features.

### Cluster identifier

The Terraform module name, file prefix, and provider alias all share the same cluster identifier:

```
<provider_prefix>_<name_prefix>_<region_slug>
```

| Provider | Prefix | Region slug format |
|---|---|---|
| AWS EKS | `eks` | `eu-west-1` (as-is) |
| Google GKE | `gke` | `europe-west1` (as-is) |
| Azure AKS | `aks` | `westeurope` (as-is) |
| Scaleway | `scw` | `fr-par` (as-is) |

Examples: `eks_gc0_eu-west-1`, `gke_gc0_europe-west1`, `aks_gc0_westeurope`, `scw_gc0_fr-par`.

---

## Repository Layout

```
.
├── Dockerfile                               # pins the Kubestack container image version
├── .gitignore                               # excludes .user/ and .terraform/
├── versions.tf                              # required_providers and version constraints
├── state.tf                                 # remote state backend (created during bootstrap)
│
├── <cluster_name>_cluster.tf                # one file per cluster
├── <cluster_name>_providers.tf              # one file per cluster
│
├── <cluster_name>_node_pool_<name>.tf       # one file per additional node pool
├── <cluster_name>_feature_<feature_name>.tf # one file per platform feature, per cluster
│
├── modules/                                 # one subdirectory per platform feature
│   └── <feature_name>/
│       ├── README.md                        # upstream source, version, and regeneration command
│       ├── versions.tf                      # required_providers for the module
│       ├── variables.tf                     # only when the module has input variables
│       ├── outputs.tf                       # only when the module exposes output values
│       ├── main.tf                          # calls the kustomization/overlay framework module
│       ├── values.yaml                      # only when upstream is a Helm chart
│       └── manifests/
│           └── upstream.yaml               # rendered Kubernetes resources for this feature
│
├── README.md
├── AGENTS.md                                # this file
└── .user/                                   # excluded from Git; persists cloud CLI auth
```

---

## Scaffolding a New Repository

When starting a brand-new repository, create the shared files below first, then scaffold the first cluster.

### `versions.tf`

Always include `kbst/kustomization` and `hashicorp/kubernetes`. Add a provider entry for every cloud provider the repository uses.

```
terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }

    kustomization = {
      source = "kbst/kustomization"
    }
  }
}
```

Add to `required_providers` as needed:
- AWS: `aws = { source = "hashicorp/aws" }`
- Azure: `azurerm = { source = "hashicorp/azurerm" }`
- GCP: `google = { source = "hashicorp/google" }`
- Scaleway: `scaleway = { source = "scaleway/scaleway" }`

### `state.tf`

Create this file only after the user has provisioned remote state storage and all required values are known. If the user has not yet decided on a backend, ask them before writing this file. Once decided, record the choice in the Configuration table in `README.md` under a "State backend" row.

The remote state backend does not need to match the cloud provider used for the cluster. Any backend that OpenTofu/Terraform supports may be used.

#### Bucket naming

Object storage bucket and container names must be globally unique. To avoid collisions, append the short git hash of the repository's initial commit as a suffix:

```
terraform-state-kubestack-<short-hash>
e.g. terraform-state-kubestack-a1b2c3d
```

The short hash ties the bucket name to this specific repository and is stable. Obtain it by running inside the repository after the first commit:

```
git rev-parse --short HEAD
```

If the repository has no commits yet, ask the user to make an initial commit first, then run the command.

This naming pattern applies to: the bucket name for AWS S3, GCS, and Scaleway; and the container name for Azure Blob Storage (the storage account name is pre-existing and supplied by the user separately).

**AWS S3:**
```
terraform {
  backend "s3" {
    bucket = "<bucket-name>"
    region = "<region>"
    key    = "tfstate"
  }
}
```

**Google Cloud Storage:**
```
terraform {
  backend "gcs" {
    bucket = "<bucket-name>"
  }
}
```

**Azure Blob Storage:**
```
terraform {
  backend "azurerm" {
    storage_account_name = "<storage-account>"
    container_name       = "<container-name>"
    key                  = "tfstate"
  }
}
```

**Scaleway Object Storage** (S3-compatible; bucket must already exist):
```
terraform {
  backend "s3" {
    bucket = "<bucket-name>"
    key    = "tfstate"

    # Replace <region> with your bucket region, e.g. fr-par, nl-ams, pl-waw.
    region   = "<region>"
    endpoint = "https://s3.<region>.scw.cloud"

    # Credentials: set SCW_ACCESS_KEY and SCW_SECRET_KEY environment variables.
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    use_path_style              = true
  }
}
```

For any other supported backend, refer to the [OpenTofu backend documentation](https://opentofu.org/docs/language/settings/backends/).

### `Dockerfile`

The Dockerfile pins the Kubestack container image version used for CI/CD and local operations. The image version must always match the `?ref=` version used in all module sources — see [Framework Version](#framework-version). Read the version from `README.md`, or ask the user when initialising a new repository.

---

## Configuration Inheritance

Every module takes a `configuration` map keyed by environment name and an optional `configuration_base_key`.

- `configuration_base_key` defaults to `apps`. All other environment keys inherit every attribute from the base.
- An attribute set in a non-base environment overrides the inherited value.
- An attribute absent from a non-base environment is transparently inherited from the base.
- It is **not** possible to unset an inherited value by setting it to `null`.
- **Keys in the `configuration` map MUST be ordered from most critical to least critical environment** (e.g. `apps-prod`, then `apps`, then `ops`). This matches the mental model of most-important-first and makes the blast-radius priority immediately visible when reading the file.

### Default two-environment layout

```
configuration = {
  apps = {
    # All required and optional attributes go here.
    # ops inherits everything and may override individual values.
  }

  ops = {}
}
```

### Three-environment layout

When the user wants a separate production environment, use `apps-prod` as the base:

```
configuration_base_key = "apps-prod"

configuration = {
  apps-prod = {
    # Production values — this is the base all others inherit from.
  }

  apps = {
    # Non-prod overrides, e.g. smaller instance type or replica count.
  }

  ops = {
    # Internal validation environment overrides.
  }
}
```

### Scaling down non-production environments

Always set full production-scale values in the base environment and override only cost-sensitive attributes in non-production environments.

**EKS example:**
```
configuration = {
  apps = {
    # ... other required attributes ...
    default_node_pool = {
      instance_types   = ["m5.xlarge"]
      min_size         = 3
      max_size         = 18
      desired_capacity = 3
    }
  }

  ops = {
    default_node_pool = {
      instance_types   = ["t3.medium"]
      min_size         = 1
      max_size         = 3
      desired_capacity = 1
    }
  }
}
```

**GKE example** (`min_node_count` / `max_node_count` are per zone):
```
ops = {
  default_node_pool = {
    machine_type   = "e2-medium"
    min_node_count = 1
    max_node_count = 1
  }
}
```

**AKS example:**
```
ops = {
  default_node_pool = {
    vm_size   = "Standard_B2s"
    min_count = 1
    max_count = 3
  }
}
```

---

## Scaffolding a Cluster

Each cluster requires exactly two files: `<cluster_name>_cluster.tf` and `<cluster_name>_providers.tf`.

Before writing either file:
1. Read `base_domain`, environment names, and framework version from the Platform section of `README.md`.
2. Read any existing cluster entries to confirm the `name_prefix` convention already in use.

### Provider aliasing

Every provider in a cluster's providers file carries an `alias` equal to the cluster identifier. This applies uniformly to all providers: the cloud provider (`aws`, `google`, `azurerm`, `scaleway`), `kustomization`, and `kubernetes`. Uniform aliasing means the same rule applies to every provider in every file with no per-provider exceptions.

Each module type receives only the providers it actually requires:

| Module type | Providers to pass |
|---|---|
| Cluster module | Cloud provider only (`aws`, `google`, `azurerm`, or `scaleway`) |
| Node-pool module | Cloud provider only (`aws`, `google`, `azurerm`, or `scaleway`) |
| Platform feature module | `kustomization` only |

The `kubernetes` provider is defined in the providers file so it is available for direct resource use if needed, but it is not passed into cluster or node-pool modules.

### Required values

If any of the following are not yet in the Platform section of `README.md`, ask the user, record the answers, then write the files.

| Value | Where it goes |
|---|---|
| `name_prefix` | Inside `configuration.apps` |
| `base_domain` | Inside `configuration.apps` |
| Region | Provider block or `configuration.apps` depending on provider |
| Availability zones | Inside `configuration.apps` (commented-out placeholder if unknown) |
| Instance / node type | Inside `configuration.apps.default_node_pool` |
| `min_size` and `max_size` (or equivalent) | Inside `configuration.apps.default_node_pool` |

The cluster's `configuration` map must include a key for every environment already in use in the repository. An empty `ops = {}` entry ensures that environment inherits from the base with no overrides.

### EKS (AWS)

**`eks_<name_prefix>_<region>_cluster.tf`**

```
module "eks_gc0_eu-west-1" {
  providers = {
    aws = aws.eks_gc0_eu-west-1
  }

  source = "github.com/kbst/terraform-kubestack//aws/cluster?ref=<version>"

  configuration = {
    apps = {
      name_prefix = "gc0"
      base_domain = "infra.example.com"

      default_node_pool = {
        instance_types   = ["t3.xlarge"]
        min_size         = 3
        max_size         = 9
        desired_capacity = 3
      }

      # EKS requires a minimum of 2 availability zones. Must match the region in the provider.
      # cluster_availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
    }

    ops = {}
  }
}
```

**`eks_<name_prefix>_<region>_providers.tf`**

```
provider "aws" {
  alias  = "eks_gc0_eu-west-1"
  region = "eu-west-1"
}

provider "kustomization" {
  alias          = "eks_gc0_eu-west-1"
  kubeconfig_raw = module.eks_gc0_eu-west-1.kubeconfig
}

locals {
  eks_gc0_eu-west-1_kubeconfig = yamldecode(module.eks_gc0_eu-west-1.kubeconfig)
}

provider "kubernetes" {
  alias = "eks_gc0_eu-west-1"

  host                   = local.eks_gc0_eu-west-1_kubeconfig["clusters"][0]["cluster"]["server"]
  cluster_ca_certificate = base64decode(local.eks_gc0_eu-west-1_kubeconfig["clusters"][0]["cluster"]["certificate-authority-data"])
  token                  = local.eks_gc0_eu-west-1_kubeconfig["users"][0]["user"]["token"]
}
```

### GKE (Google Cloud)

**`gke_<name_prefix>_<region>_cluster.tf`**

```
module "gke_gc0_europe-west1" {
  providers = {
    google = google.gke_gc0_europe-west1
  }

  source = "github.com/kbst/terraform-kubestack//google/cluster?ref=<version>"

  configuration = {
    apps = {
      name_prefix = "gc0"
      base_domain = "infra.example.com"

      # project_id = "my-gcp-project"
      # region     = "europe-west1"

      cluster_min_master_version = "1.30"

      default_node_pool = {
        # machine_type   = "e2-standard-4"
        # min_node_count = 1
        # max_node_count = 3
      }

      # Zones must be within the region above.
      # cluster_node_locations = ["europe-west1-b", "europe-west1-c", "europe-west1-d"]
    }

    ops = {}
  }
}
```

**`gke_<name_prefix>_<region>_providers.tf`**

```
provider "google" {
  alias = "gke_gc0_europe-west1"
  # project and region are passed inside the cluster module configuration.
  # Set them here only if you want a provider-level default.
  # project = "my-gcp-project"
  # region  = "europe-west1"
}

provider "kustomization" {
  alias          = "gke_gc0_europe-west1"
  kubeconfig_raw = module.gke_gc0_europe-west1.kubeconfig
}

locals {
  gke_gc0_europe-west1_kubeconfig = yamldecode(module.gke_gc0_europe-west1.kubeconfig)
}

provider "kubernetes" {
  alias = "gke_gc0_europe-west1"

  host                   = local.gke_gc0_europe-west1_kubeconfig["clusters"][0]["cluster"]["server"]
  cluster_ca_certificate = base64decode(local.gke_gc0_europe-west1_kubeconfig["clusters"][0]["cluster"]["certificate-authority-data"])
  token                  = local.gke_gc0_europe-west1_kubeconfig["users"][0]["user"]["token"]
}
```

### AKS (Azure)

**`aks_<name_prefix>_<region>_cluster.tf`**

```
module "aks_gc0_westeurope" {
  providers = {
    azurerm = azurerm.aks_gc0_westeurope
  }

  source = "github.com/kbst/terraform-kubestack//azurerm/cluster?ref=<version>"

  configuration = {
    apps = {
      name_prefix = "gc0"
      base_domain = "infra.example.com"

      resource_group = "my-resource-group"

      availability_zones = [1, 2, 3]

      default_node_pool = {
        # vm_size   = "Standard_D4s_v3"
        min_count = 3
        max_count = 9
      }
    }

    ops = {}
  }
}
```

**`aks_<name_prefix>_<region>_providers.tf`**

```
provider "azurerm" {
  alias = "aks_gc0_westeurope"
  features {}
}

provider "kustomization" {
  alias          = "aks_gc0_westeurope"
  kubeconfig_raw = module.aks_gc0_westeurope.kubeconfig
}

locals {
  aks_gc0_westeurope_kubeconfig = yamldecode(module.aks_gc0_westeurope.kubeconfig)
}

provider "kubernetes" {
  alias = "aks_gc0_westeurope"

  host                   = local.aks_gc0_westeurope_kubeconfig["clusters"][0]["cluster"]["server"]
  cluster_ca_certificate = base64decode(local.aks_gc0_westeurope_kubeconfig["clusters"][0]["cluster"]["certificate-authority-data"])
  token                  = local.aks_gc0_westeurope_kubeconfig["users"][0]["user"]["token"]
}
```

### Scaleway (Kapsule)

**`scw_<name_prefix>_<region>_cluster.tf`**

```
module "scw_gc0_fr-par" {
  providers = {
    scaleway = scaleway.scw_gc0_fr-par
  }

  source = "github.com/kbst/terraform-kubestack//scaleway/cluster?ref=<version>"

  configuration = {
    apps = {
      name_prefix = "gc0"
      base_domain = "infra.example.com"

      region = "fr-par"

      default_node_pool = {
        node_type = "PRO2-S"

        zones = ["fr-par-1", "fr-par-2", "fr-par-3"]

        min_size = 1
        max_size = 3
      }
    }

    ops = {}
  }
}
```

**`scw_<name_prefix>_<region>_providers.tf`**

```
provider "scaleway" {
  alias  = "scw_gc0_fr-par"
  region = "fr-par"
}

provider "kustomization" {
  alias          = "scw_gc0_fr-par"
  kubeconfig_raw = module.scw_gc0_fr-par.kubeconfig
}

locals {
  scw_gc0_fr-par_kubeconfig = yamldecode(module.scw_gc0_fr-par.kubeconfig)
}

provider "kubernetes" {
  alias = "scw_gc0_fr-par"

  host                   = local.scw_gc0_fr-par_kubeconfig["clusters"][0]["cluster"]["server"]
  cluster_ca_certificate = base64decode(local.scw_gc0_fr-par_kubeconfig["clusters"][0]["cluster"]["certificate-authority-data"])
  token                  = local.scw_gc0_fr-par_kubeconfig["users"][0]["user"]["token"]
}
```

---

## Adding a Cluster

Adding a cluster is a three-stage process — cluster first, then node pools, then platform features — each in its own GitOps cycle. This mirrors the reverse order used when removing a cluster and for the same reason: the Terraform dependency graph does not track cross-stage dependencies, and applying everything at once risks partial failures that are difficult to recover from.

Your work at each stage is to prepare the file changes for that stage only, hand off to the user with the GitOps follow-up instructions, and wait for confirmation that the pipeline has successfully applied before preparing the next stage.

### Stage 1 — Discovery and cluster scaffold

Before writing any files, if not clear from the user's prompt already, hold a short discovery conversation with the user to establish the answers to these questions in order. Record each answer in the Clusters table in `README.md` as it is confirmed — do not re-ask on subsequent stages.

**Question 1 — Same cloud and region, or new?**

| Scenario | Implication |
|---|---|
| Same cloud, same region, same purpose | Adding capacity. Mirror the existing cluster of that type exactly — same instance types, same node pool shape, same features. The only difference is the incremented `name_prefix` counter. |
| Same cloud, same region, different purpose | New workload type. Mirror the existing cluster's structural decisions (environment layout, node pool autoscaling approach, features) but adapt instance types and any purpose-specific configuration to the new workload. |
| Same cloud, new region | Geographic expansion. Mirror the existing cluster of the same purpose in the original region as closely as possible. Adapt only what the new region requires (availability zone names, region-specific instance type availability). |
| New cloud provider | Multi-cloud addition. Mirror the existing cluster of the same purpose as closely as possible across the provider boundary. Adapt provider-specific attributes (instance type naming, zone format, auth model) but keep the configuration structure and scale identical. |

**Question 2 — What is the purpose of the new cluster?**

Use the answer to confirm or choose the `name_prefix` following the rules in [Naming Rules → `name_prefix`](#name_prefix). Present the derived name to the user and confirm before proceeding.

**Question 3 — Which existing cluster is the closest match to mirror?**

Read the Clusters table in `README.md`. Identify the cluster that best matches the answers above — same cloud provider first, then same purpose. Present your choice to the user and confirm before reading that cluster's `.tf` files to extract the configuration to mirror.

Once the three questions are answered and confirmed, proceed with the scaffold:

1. Read environment names, `base_domain`, and framework version from the Platform section of `README.md`.
2. Derive the `<cluster_name>` from the confirmed `name_prefix`, cloud provider, and region.
3. Read the matched cluster's `<cluster_name>_cluster.tf` and `<cluster_name>_providers.tf` to extract the configuration to mirror.
4. Create `<cluster_name>_cluster.tf` for the new cluster, mirroring the matched cluster's configuration. Adapt only what differs: region, availability zones, and any provider-specific attributes that the new region or cloud requires.
5. Create `<cluster_name>_providers.tf` for the new cluster.
6. If the new cluster uses a cloud provider not yet declared in `versions.tf`, add it.
7. Add a row for the new cluster to the Clusters table in `README.md`.
8. Give the user the GitOps follow-up instructions. Remind them that node pools and platform features must follow in separate stages once this pipeline has successfully applied.

### Stage 2 — Add node pools

Once the user confirms the cluster pipeline has applied successfully, mirror the node pools from the matched cluster. For each additional node pool on the matched cluster, scaffold a corresponding `<new_cluster_name>_node_pool_<name>.tf` following [Scaffolding an Additional Node Pool](#scaffolding-an-additional-node-pool). Adapt region-specific attributes (availability zones, instance type names) as needed.

Give the user the GitOps follow-up instructions. Remind them that platform features must follow in a separate stage.

### Stage 3 — Add platform features

Once the user confirms the node pool pipeline has applied successfully, mirror the platform features from the matched cluster. For each feature on the matched cluster, create the corresponding `<new_cluster_name>_feature_<feature_name>.tf` binding file following [Scaffolding a Platform Feature](#scaffolding-a-platform-feature). The `modules/<feature_name>/` directory already exists — only the cluster-binding file is new.

Give the user the GitOps follow-up instructions.

---

### Multi-cloud and multi-region notes

When the new cluster uses a cloud provider not already in the repository, `versions.tf` must declare it. Each cluster's pair of files is completely independent — there are no cross-cluster dependencies in Kubestack. However, the `modules/<feature_name>/` directories are shared across all clusters; no changes to them are needed when adding a cluster-binding file for an existing feature.

---

## Scaffolding an Additional Node Pool

Every cluster includes a default node pool configured inside the cluster module. Additional node pools are defined in separate files.

### File naming

```
<cluster_name>_node_pool_<pool_name>.tf
```

Example: `eks_gc0_eu-west-1_node_pool_gpu.tf`

Read the cluster name from the Clusters table in `README.md`. The pool name must reflect the purpose of the pool: `extra`, `gpu`, `spot`, `arm`, etc.

### Required values

| Value | Notes |
|---|---|
| Pool name | Short identifier reflecting purpose |
| Instance / node type | Provider-specific VM size |
| `min_size` / `max_size` (or equivalent) | Autoscaling bounds |
| Zones | Must be within the cluster's region |
| Taints and labels | Required if the pool is dedicated to a workload type |

### EKS node pool

```
module "eks_gc0_eu-west-1_node_pool_extra" {
  providers = {
    aws = aws.eks_gc0_eu-west-1
  }

  source = "github.com/kbst/terraform-kubestack//aws/cluster/node-pool?ref=<version>"

  cluster_name = module.eks_gc0_eu-west-1.current_metadata["name"]

  configuration = {
    apps = {
      name = "extra"

      instance_types   = ["t3a.xlarge"]
      min_size         = 3
      max_size         = 9
      desired_capacity = 3

      availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
    }

    ops = {}
  }
}
```

`cluster_name` must reference `module.<cluster_name>.current_metadata["name"]` — never hardcode the cluster name string.

### GKE node pool

```
module "gke_gc0_europe-west1_node_pool_extra" {
  providers = {
    google = google.gke_gc0_europe-west1
  }

  source = "github.com/kbst/terraform-kubestack//google/cluster/node-pool?ref=<version>"

  cluster_metadata = module.gke_gc0_europe-west1.current_metadata

  configuration = {
    apps = {
      name = "extra"

      project_id = module.gke_gc0_europe-west1.current_config["project_id"]
      location   = module.gke_gc0_europe-west1.current_config["region"]

      machine_type       = "e2-standard-4"
      initial_node_count = 1
      min_node_count     = 1
      max_node_count     = 3
    }

    ops = {}
  }
}
```

Pass cluster identity via `cluster_metadata`. Always pull `project_id` and `location` from `module.<cluster_name>.current_config`.

### AKS node pool

```
module "aks_gc0_westeurope_node_pool_extra" {
  providers = {
    azurerm = azurerm.aks_gc0_westeurope
  }

  source = "github.com/kbst/terraform-kubestack//azurerm/cluster/node-pool?ref=<version>"

  cluster_name   = module.aks_gc0_westeurope.current_metadata["name"]
  resource_group = module.aks_gc0_westeurope.current_config["resource_group"]

  configuration = {
    apps = {
      node_pool_name = "extra"

      vm_size    = "Standard_D4s_v3"
      node_count = 3
      min_count  = 3
      max_count  = 9

      availability_zones = [1, 2, 3]
    }

    ops = {}
  }
}
```

AKS node pools require both `cluster_name` and `resource_group` as top-level inputs. Always reference these from the cluster module's outputs.

### Taints and labels

Use taints when the pool is dedicated to a specific workload type (GPU, spot, machine-learning). Use labels for soft scheduling preferences.

**EKS taint and label example:**
```
apps = {
  name             = "gpu"
  instance_types   = ["g4dn.xlarge"]
  min_size         = 0
  max_size         = 4
  desired_capacity = 0

  taints = [
    {
      key    = "nvidia.com/gpu"
      value  = "true"
      effect = "NO_SCHEDULE"
    }
  ]

  labels = {
    "nvidia.com/gpu" = "true"
  }
}
```

---

## Removing a Node Pool

1. Delete `<cluster_name>_node_pool_<name>.tf`.
2. Remove the corresponding row from the Node Pools table in `README.md`.

Your work ends there — do not run any git or terraform commands. Give the user the GitOps follow-up instructions. The Terraform plan on the feature branch will show the node pool resources being destroyed — this is the expected signal for the reviewer to approve the deletion.

---

## Scaffolding a Platform Feature

A platform feature is a set of Kubernetes resources applied to one or more clusters. Each feature is implemented as a local Terraform module under `modules/<feature_name>/` that wraps the Kubestack `kustomization/overlay` framework module. A separate root-level file per cluster calls that local module and wires in the correct `kustomization` provider alias.

### Files

| File | Always created | Purpose |
|---|---|---|
| `modules/<feature_name>/README.md` | Yes | Upstream source, version, and regeneration command — source of truth for updates |
| `modules/<feature_name>/manifests/upstream.yaml` | Yes | Rendered Kubernetes resources for this feature, separated by `---` |
| `modules/<feature_name>/versions.tf` | Yes | `required_providers` for the module — needed to specify the correct local provider name `kbst/kustomization` and prevent invalid fallback `hashicorp/kustomization` |
| `modules/<feature_name>/main.tf` | Yes | Calls the `kustomization/overlay` framework module |
| `modules/<feature_name>/variables.tf` | Only if the module has input variables | Input variable declarations |
| `modules/<feature_name>/outputs.tf` | Only if the module exposes output values | Output value declarations |
| `modules/<feature_name>/values.yaml` | Only when upstream is a Helm chart | Helm values configured for the most critical environment |
| `<cluster_name>_feature_<feature_name>.tf` | Yes, one per target cluster | Calls the feature module with the cluster's `kustomization` provider alias |

### Naming

`<feature_name>` is a short snake_case identifier, e.g. `gateway_api`, `service_mesh`, `cert_manager`. It is used as the module directory name, the local module name, and the suffix of the cluster-binding file.

### Step 1 — Discover the upstream source

Before writing any files, proactively determine the best upstream source for the feature the user has asked for. Do **not** open with a question — lead with a concrete recommendation.

#### 1a — Research known sources

Using your training knowledge, look up the feature by name across these well-known registries and distribution channels (in preference order):

| Source | What it hosts | Prefer when |
|---|---|---|
| [Artifact Hub](https://artifacthub.io) | Helm charts, plain YAML operators, OLM bundles, and more | Always check here first — it indexes the canonical chart/manifest for almost every popular project |
| GitHub Releases | Versioned plain YAML install manifests | Project publishes a single `install.yaml` or `deploy.yaml` as a release asset |
| OCI Helm registries (`oci://ghcr.io/…`, `oci://registry-1.docker.io/…`) | Immutable, digest-pinned Helm charts | Project publishes to GHCR or Docker Hub OCI; prefer over a traditional Helm repo |
| Traditional Helm repos (`https://charts.<project>.io/`) | Helm charts via `helm repo add` | No OCI distribution exists |
| Operator Hub / OLM | Kubernetes operators | Feature is operator-based and targets OpenShift or OLM-enabled clusters |

Well-known examples to draw from (non-exhaustive):

- **cert-manager** — Helm chart at `oci://quay.io/jetstack/cert-manager` *and* plain YAML at `https://github.com/cert-manager/cert-manager/releases/download/<version>/cert-manager.yaml`. Artifact Hub: `https://artifacthub.io/packages/helm/cert-manager/cert-manager`.
- **Prometheus / kube-prometheus-stack** — Helm chart `oci://ghcr.io/prometheus-community/charts/kube-prometheus-stack`. Artifact Hub: `https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack`.
- **Argo CD** — plain YAML at `https://raw.githubusercontent.com/argoproj/argo-cd/<version>/manifests/install.yaml` *and* Helm chart via `https://argoproj.github.io/argo-helm`. Artifact Hub: `https://artifacthub.io/packages/helm/argo/argo-cd`.
- **Flux CD** — plain YAML via the `flux` CLI (`flux install --export`) *or* Helm chart at `oci://ghcr.io/fluxcd-community/charts/flux2`. Artifact Hub: `https://artifacthub.io/packages/helm/fluxcd-community/flux2`.
- **Crossplane** — Helm chart at `oci://xpkg.upbound.io/crossplane-contrib/chart/crossplane`. Artifact Hub: `https://artifacthub.io/packages/helm/crossplane/crossplane`.
- **External Secrets Operator** — Helm chart `oci://ghcr.io/external-secrets/charts/external-secrets`. Artifact Hub: `https://artifacthub.io/packages/helm/external-secrets-operator/external-secrets`.
- **Sealed Secrets** — Helm chart at `oci://ghcr.io/bitnami-labs/sealed-secrets-chart` *and* plain YAML at `https://github.com/bitnami-labs/sealed-secrets/releases/download/<version>/controller.yaml`. Artifact Hub: `https://artifacthub.io/packages/helm/sealed-secrets/sealed-secrets`.
- **Velero** — Helm chart via `https://vmware-tanzu.github.io/helm-charts` (chart: `velero/velero`). Artifact Hub: `https://artifacthub.io/packages/helm/vmware-tanzu/velero`.
- **Karpenter** — Helm chart at `oci://public.ecr.aws/karpenter/karpenter`. Artifact Hub: `https://artifacthub.io/packages/helm/karpenter/karpenter`.
- **Metrics Server** — Helm chart at `https://kubernetes-sigs.github.io/metrics-server/` *and* plain YAML at `https://github.com/kubernetes-sigs/metrics-server/releases/download/<version>/components.yaml`. Artifact Hub: `https://artifacthub.io/packages/helm/metrics-server/metrics-server`.
- **Gateway API (CRDs)** — plain YAML at `https://github.com/kubernetes-sigs/gateway-api/releases/download/<version>/standard-install.yaml`.

#### 1b — Present a recommendation and get confirmation

Present what you found to the user. Include:

1. The canonical upstream source (Artifact Hub URL if one exists, plus the actual chart or manifest URL).
2. The latest stable version you are aware of (note that your training data has a cutoff and the user should verify).
3. Whether it is a Helm chart or a plain YAML manifest, and which specific format you recommend (OCI Helm > traditional Helm repo > plain YAML, all else being equal).
4. A brief reason for your recommendation (e.g. "OCI distribution is available and preferred because chart versions are immutable").

Example recommendation message:

> I found **cert-manager** on Artifact Hub: https://artifacthub.io/packages/helm/cert-manager/cert-manager
>
> Recommended source: Helm chart via OCI at `oci://quay.io/jetstack/cert-manager`, latest stable version `v1.16.2` (verify at https://github.com/cert-manager/cert-manager/releases).
> OCI is preferred over the traditional Helm repo because the reference is immutable and version-pinned by digest.
>
> Shall I proceed with this source, or would you like to use a different one?

If the user accepts: proceed with the recommended source and format.

If no matching source could be found, or the user wants a different source: ask the user to provide the upstream source URL, confirm whether it is a plain YAML manifest or a Helm chart, then proceed with what they supply.

#### 1c — Choose the path based on format

- Helm chart (OCI or traditional repo) → follow the [Helm chart path](#helm-chart-path).
- Plain YAML manifest → follow the [Plain YAML path](#plain-yaml-path).

---

### Plain YAML path

Upstream publishes a versioned YAML manifest (e.g. a GitHub release asset or a URL such as `https://github.com/<org>/<repo>/releases/download/<version>/install.yaml`).

1. Fetch the upstream manifest and write its full contents into `modules/<feature_name>/manifests/upstream.yaml`.
2. Create `modules/<feature_name>/README.md` recording:
   - The upstream project name and URL.
   - The exact URL or release tag the manifest was fetched from.
   - The version installed.
   - Instructions for how to update: fetch the new release URL and overwrite `upstream.yaml`, then re-run `tofu validate`.

Example `README.md`:

```
# <feature_name>

## Upstream source

- Project: <upstream project URL>
- Manifest URL: <exact URL fetched>
- Version: <version>

## Updating

1. Find the new release at <upstream releases URL>.
2. Fetch the new manifest: `curl -L <new manifest URL> -o modules/<feature_name>/manifests/upstream.yaml`
3. Review the diff for breaking changes.
4. Commit `manifests/upstream.yaml` and follow the GitOps workflow.
```

---

### Helm chart path

Upstream publishes a Helm chart. Prefer the OCI registry distribution if the upstream project provides one (e.g. `oci://registry-1.docker.io/...` or `oci://ghcr.io/...`) over a traditional Helm repository, as OCI references are immutable and version-pinned by digest.

**1. Create `modules/<feature_name>/values.yaml`**

Configure Helm values for the most critical environment (the base environment — `apps` or `apps-prod` as recorded in `README.md`). This file is the production-faithful baseline. Do not add special-casing or reduced configuration here; those belong in the per-environment overrides in `main.tf`.

```yaml
# values.yaml — configured for the <base_environment> (most critical) environment.
# Overrides for less critical environments are applied via the kustomization/overlay
# configuration map in main.tf, not here.
```

Populate it with the values appropriate for production scale and configuration.

**2. Render `upstream.yaml` using `helm template`**

> `upstream.yaml` is a generated file. Never edit it directly. To change what is rendered, edit `values.yaml` and re-run the `helm template` command to regenerate it.

Run `helm template` to render the chart with `values.yaml` into `modules/<feature_name>/manifests/upstream.yaml`. Always include `--include-crds` and `--create-namespace` so that the namespace, any CRDs, and all other resources are emitted into a single file. The kustomization provider handles creation order automatically — there is no need to split these into separate files or apply them in separate steps.

The exact command depends on whether the chart is OCI-distributed or repo-based:

OCI:
```
helm template <release-name> oci://<registry>/<chart> \
  --version <chart-version> \
  --values modules/<feature_name>/values.yaml \
  --namespace <namespace> \
  --create-namespace \
  --include-crds \
  > modules/<feature_name>/manifests/upstream.yaml
```

Helm repo:
```
helm repo add <repo-name> <repo-url>
helm template <release-name> <repo-name>/<chart-name> \
  --version <chart-version> \
  --values modules/<feature_name>/values.yaml \
  --namespace <namespace> \
  --create-namespace \
  --include-crds \
  > modules/<feature_name>/manifests/upstream.yaml
```

The resulting `upstream.yaml` will contain the Namespace resource, all CRDs (if any), and every other resource the chart installs. This is intentional — it is the complete, self-contained description of what the feature installs.

You cannot run these commands — provide the exact command to the user and ask them to run it, then confirm the output was written to `upstream.yaml` before proceeding.

**3. Create `modules/<feature_name>/README.md`** recording:
   - The upstream project name and URL.
   - The chart source: OCI reference or repo URL and chart name.
   - The chart version installed.
   - The exact `helm template` command used to regenerate `upstream.yaml`.
   - Instructions for how to update.

Example `README.md`:

```
# <feature_name>

## Upstream source

- Project: <upstream project URL>
- Chart: oci://<registry>/<chart>  (or <repo-name>/<chart-name> from <repo-url>)
- Version: <chart-version>

## Regenerating upstream.yaml

Run the following command from the repository root, then commit the result:

    helm template <release-name> oci://<registry>/<chart> \
      --version <chart-version> \
      --values modules/<feature_name>/values.yaml \
      --namespace <namespace> \
      --create-namespace \
      --include-crds \
      > modules/<feature_name>/manifests/upstream.yaml

## Updating

1. Find the new chart version at <upstream releases URL>.
2. Update the `--version` flag in the command above.
3. Re-run the command, review the diff for breaking changes.
4. Update the Version line in this file.
5. Commit `manifests/upstream.yaml` and `README.md` and follow the GitOps workflow.
```

---

### kustomization/overlay configuration attributes reference

Every key inside a `configuration` environment block maps directly to a Kustomize attribute exposed by the `kustomization/overlay` module. Use the full set below when writing or patching `main.tf`.

```
configuration = {
  apps = {
    # -------------------------------------------------------------------------
    # resources (required in the base environment)
    # List of paths to YAML files or Kustomization directories to deploy.
    # Always reference upstream.yaml via ${path.module} so the path resolves
    # correctly regardless of where OpenTofu is invoked from.
    # -------------------------------------------------------------------------
    resources = [
      "${path.module}/manifests/upstream.yaml",
    ]

    # -------------------------------------------------------------------------
    # namespace (optional, default: null)
    # Sets metadata.namespace on every resource that does not already have one.
    # Use when the chart does not set namespaces on all resources, or when you
    # want to force all resources into a single namespace.
    # -------------------------------------------------------------------------
    namespace = "example"

    # -------------------------------------------------------------------------
    # common_labels (optional, default: null)
    # Adds or overrides labels on every resource and every pod template.
    # -------------------------------------------------------------------------
    common_labels = {
      "env" = terraform.workspace
    }

    # -------------------------------------------------------------------------
    # common_annotations (optional, default: null)
    # Adds or overrides annotations on every resource.
    # -------------------------------------------------------------------------
    common_annotations = {
      "example-annotation" = "value"
    }

    # -------------------------------------------------------------------------
    # name_prefix / name_suffix (optional, default: null)
    # Prepends or appends a string to the metadata.name of every resource.
    # -------------------------------------------------------------------------
    name_prefix = "prefix-"
    name_suffix = "-suffix"

    # -------------------------------------------------------------------------
    # images (optional, default: null)
    # Patches image names, tags, or digests on pod specs without touching the
    # YAML directly. 'name' refers to the container name in pod.spec.containers.
    # -------------------------------------------------------------------------
    images = [
      {
        name     = "example"
        new_name = "registry.example.com/example"
        new_tag  = "v1.2.3"
        # digest replaces new_tag when set:
        # digest = "sha256:..."
      }
    ]

    # -------------------------------------------------------------------------
    # replicas (optional, default: null)
    # Sets the replica count on Deployments, StatefulSets, or similar resources
    # by name. Prefer this over a JSON patch for simple replica changes.
    # -------------------------------------------------------------------------
    replicas = [
      {
        name  = "example-deployment"
        count = 3
      }
    ]

    # -------------------------------------------------------------------------
    # patches (optional, default: null)
    # Applies strategic merge patches or RFC 6902 JSON patches to one or more
    # resources. Use 'patch' for inline patches or 'path' for file-based patches.
    # 'target' narrows which resources the patch applies to.
    # -------------------------------------------------------------------------
    patches = [
      {
        # Inline JSON patch:
        patch = <<-EOF
          - op: replace
            path: /spec/replicas
            value: 1
        EOF
        target = {
          kind = "Deployment"
          name = "example"
        }
      },
      {
        # File-based strategic merge patch:
        path = "${path.module}/manifests/patch.yaml"
        target = {
          group               = "apps"
          version             = "v1"
          kind                = "Deployment"
          name                = "example"
          namespace           = "example"
          label_selector      = "app=example"
          annotation_selector = "env=ops"
        }
      }
    ]

    # -------------------------------------------------------------------------
    # config_map_generator (optional, default: null)
    # Generates ConfigMap resources from literals, env files, or plain files.
    # -------------------------------------------------------------------------
    config_map_generator = [
      {
        name      = "example-config"
        namespace = "example"
        behavior  = "create"   # "create" | "replace" | "merge"
        literals  = ["KEY=VALUE"]
        # envs  = ["${path.module}/manifests/env"]
        # files = ["${path.module}/manifests/cfg.ini"]
        options = {
          labels                 = { "example-label" = "example" }
          annotations            = { "example-annotation" = "example" }
          disable_name_suffix_hash = true
        }
      }
    ]

    # -------------------------------------------------------------------------
    # secret_generator (optional, default: null)
    # Generates Secret resources. Same shape as config_map_generator plus 'type'.
    # Do NOT inline sensitive values here — use literals only for non-secret
    # bootstrapping data, or reference env files that are never committed.
    # -------------------------------------------------------------------------
    secret_generator = [
      {
        name      = "example-secret"
        namespace = "example"
        behavior  = "create"
        type      = "generic"
        literals  = ["KEY=VALUE"]
      }
    ]

    # -------------------------------------------------------------------------
    # generator_options (optional, default: null)
    # Global options applied to all config_map_generator and secret_generator
    # entries. Per-generator 'options' blocks take precedence where both are set.
    # -------------------------------------------------------------------------
    generator_options = {
      labels                   = { "example-label" = "example" }
      annotations              = { "example-annotation" = "example" }
      disable_name_suffix_hash = true
    }

    # -------------------------------------------------------------------------
    # Low-level pass-through attributes (optional, rarely needed)
    # These map directly to Kustomize internals and are less useful in the
    # Terraform context. Include only when specifically required.
    # -------------------------------------------------------------------------
    # components    = []   # List of paths to Kustomize components
    # crds          = []   # List of paths to Kustomize CRD files
    # generators    = []   # List of paths to Kustomize generator configs
    # transformers  = []   # List of paths to Kustomize transformer configs
    # vars          = []   # List of objects defining Kustomize vars
  }

  ops = {}
}
```

### Environment patching philosophy

`values.yaml` is configured for the most critical environment and must not be diluted. Overrides for less critical environments (`ops`, and `apps` in a three-environment layout) are applied through the `configuration` map in `main.tf` using the attributes documented above — not through additional values files or conditional logic in `values.yaml`.

This keeps the base configuration honest: what is committed in `values.yaml` and `upstream.yaml` is exactly what runs in production. Differences introduced only in lower environments are explicit and reviewable in `main.tf`. This approach reduces the risk of incidents in the critical environment.

**Example — reducing replica count in `ops` using `replicas`:**

```
configuration = {
  apps = {
    resources = [
      "${path.module}/manifests/upstream.yaml",
    ]
  }

  ops = {
    replicas = [
      {
        name  = "<deployment-name>"
        count = 1
      }
    ]
  }
}
```

**Example — reducing replica count using a JSON patch (when `replicas` is not sufficient):**

```
configuration = {
  apps = {
    resources = [
      "${path.module}/manifests/upstream.yaml",
    ]
  }

  ops = {
    patches = [
      {
        patch = <<-EOF
          - op: replace
            path: /spec/replicas
            value: 1
        EOF
        target = {
          kind = "Deployment"
          name = "<deployment-name>"
        }
      }
    ]
  }
}
```

**Example — using a debug image tag in `ops`:**

```
configuration = {
  apps = {
    resources = [
      "${path.module}/manifests/upstream.yaml",
    ]
  }

  ops = {
    images = [
      {
        name    = "<container-name>"
        new_tag = "<debug-tag>"
      }
    ]
  }
}
```

**Example — injecting a workspace label on all resources:**

```
configuration = {
  apps = {
    resources = [
      "${path.module}/manifests/upstream.yaml",
    ]
    common_labels = {
      "env" = terraform.workspace
    }
  }

  ops = {}
}
```

---

### Step 2 — Create the Terraform module files

**`modules/<feature_name>/versions.tf`**

```
terraform {
  required_providers {
    kustomization = {
      source = "kbst/kustomization"
    }
  }
}
```

**`modules/<feature_name>/main.tf`**

```
module "<feature_name>" {
  providers = {
    kustomization = kustomization
  }

  source = "github.com/kbst/terraform-kubestack//kustomization/overlay?ref=<version>"

  configuration = {
    apps = {
      resources = [
        "${path.module}/manifests/upstream.yaml",
      ]
    }

    ops = {}
  }
}
```

`${path.module}` always resolves to the directory of `main.tf`. Use the same `?ref=<version>` value as all other modules in the repository — read it from the Configuration table in `README.md`.

Add per-environment `patches` blocks to the `configuration` map as needed following the environment patching philosophy above.

### Step 3 — Create the cluster binding

Create one file per cluster this feature is deployed to:

**`<cluster_name>_feature_<feature_name>.tf`**

```
module "<cluster_name>_feature_<feature_name>" {
  providers = {
    kustomization = kustomization.<cluster_name>
  }

  source = "./modules/<feature_name>"
}
```

If the feature is deployed to multiple clusters, each cluster gets its own file with the corresponding `kustomization` alias.

### Checklist

1. Choose a `<feature_name>` in snake_case.
2. Research the upstream source using the ArtifactHub-first lookup in Step 1. Present your recommendation and get confirmation before writing any files. Fall back to asking the user only if no known source is found or the user prefers a different one.
3. Create `modules/<feature_name>/README.md` (source, version, regeneration command).
4. Populate `modules/<feature_name>/manifests/upstream.yaml` with the rendered upstream resources.
5. Create `modules/<feature_name>/values.yaml` only if upstream is a Helm chart.
6. Create `modules/<feature_name>/versions.tf`.
7. Create `modules/<feature_name>/main.tf` with appropriate per-environment patches.
8. Create `modules/<feature_name>/variables.tf` only if the module requires input variables.
9. Create `modules/<feature_name>/outputs.tf` only if the module exposes output values.
10. For each target cluster, create `<cluster_name>_feature_<feature_name>.tf`.
11. Add a row for the new feature to the Platform Features table in `README.md`.
12. Give the user the GitOps follow-up instructions.

---

## Updating a Platform Feature

When a user asks to update a platform feature (one feature by name, or all features), read `modules/<feature_name>/README.md` for each feature being updated. This file is the source of truth — it records where `upstream.yaml` came from and the exact command needed to regenerate it.

### Plain YAML update

1. Read `modules/<feature_name>/README.md` to find the upstream releases URL and the current version.
2. Identify the new version to install. If the user has not specified one, ask them or check the upstream releases page together.
3. Provide the user with the fetch command from the README (updated with the new version URL) and ask them to run it to overwrite `upstream.yaml`.
4. Once the user confirms `upstream.yaml` has been updated, update the version recorded in `modules/<feature_name>/README.md`.
5. Run `tofu validate` to verify syntax.
6. Give the user the GitOps follow-up instructions.

### Helm chart update

1. Read `modules/<feature_name>/README.md` to find the chart source, current version, and the exact `helm template` command.
2. Identify the new chart version. If the user has not specified one, ask them or check the upstream releases page together.
3. Provide the user with the updated `helm template` command (with the new `--version` flag) and ask them to run it to overwrite `upstream.yaml`.
4. Once the user confirms `upstream.yaml` has been updated, review the diff with the user for any breaking changes that require `values.yaml` or `main.tf` patches to be updated.
5. Update the version recorded in `modules/<feature_name>/README.md`.
6. Run `tofu validate` to verify syntax.
7. Give the user the GitOps follow-up instructions.

### Updating all platform features

Read `modules/*/README.md` for every feature module in the repository and apply the appropriate update path for each. Perform each feature update as a separate task — do not batch multiple feature updates into a single commit, as this makes the Terraform plan harder to review and a single breaking change harder to isolate.

---

## Removing a Platform Feature

A platform feature may be removed from a single cluster or from all clusters. The steps differ depending on scope, but the module check at the end always applies.

### Remove the cluster-binding files

Delete the `<cluster_name>_feature_<feature_name>.tf` file for each cluster the feature is being removed from. Remove the corresponding rows from the Platform Features table in `README.md`.

### Check whether the feature module is still in use

After deleting the binding files, check whether any `<cluster_name>_feature_<feature_name>.tf` files for this feature remain anywhere in the repository.

**If binding files remain** — other clusters still use this feature. The `modules/<feature_name>/` directory must be kept. Your work ends here.

**If no binding files remain** — the feature module is now unused. Ask the user: *"No clusters reference this feature any more. Should I delete the `modules/<feature_name>/` directory as well, or keep it for future use?"*

- If the user wants it deleted: delete `modules/<feature_name>/` and all files within it.
- If the user wants it kept: leave it in place.

Your work ends there — do not run any git or terraform commands. Give the user the GitOps follow-up instructions. The Terraform plan on the feature branch will show the feature resources being destroyed — this is the expected signal for the reviewer to approve the deletion.

---

## Removing a Cluster

Remove a cluster in three separate stages. Each stage is an independent unit of work: you make the file changes, hand off to the user with the GitOps follow-up instructions, and wait for the user to confirm the pipeline has successfully applied before you begin the next stage. This minimises disruption and avoids interdependencies during shutdown that the Terraform dependency graph does not track.

### Stage 1 — Remove all platform features

For each platform feature bound to this cluster, follow the full [Removing a Platform Feature](#removing-a-platform-feature) process. This includes the module usage check for each feature — a feature module must be deleted if this cluster was its last binding, or kept if other clusters still reference it.

Your work ends there — do not run any git or terraform commands. Give the user the GitOps follow-up instructions. The Terraform plan will show the platform feature resources being destroyed — this is the expected signal for the reviewer to approve. The user must complete the full GitOps cycle and confirm the pipeline has successfully applied before asking you to proceed to Stage 2.

### Stage 2 — Remove all additional node pools

1. Delete every `<cluster_name>_node_pool_<name>.tf` file for this cluster.
2. Remove the corresponding rows from the Node Pools table in `README.md`.

Your work ends there — do not run any git or terraform commands. Give the user the GitOps follow-up instructions. The Terraform plan will show the node pool resources being destroyed — this is the expected signal for the reviewer to approve. The user must complete the full GitOps cycle and confirm the pipeline has successfully applied before asking you to proceed to Stage 3.

### Stage 3 — Remove the cluster and its providers

1. Delete `<cluster_name>_cluster.tf`.
2. Delete `<cluster_name>_providers.tf`.
3. Remove the corresponding row from the Clusters table in `README.md`.

Your work ends there — do not run any git or terraform commands. Give the user the GitOps follow-up instructions. The Terraform plan will show all remaining cluster infrastructure being destroyed — this is the expected signal for the reviewer to approve.

---

## GitOps Workflow

All infrastructure changes follow this four-step process. Your role is to produce correct Terraform files and hand off to the user. Applying changes is always the responsibility of the GitOps pipeline — a human must approve before anything executes against real infrastructure.

1. **Change** — Make changes in a feature branch. Push the branch. The pipeline runs `tofu plan` against the `ops` workspace.
2. **Review** — A peer reviews the diff and the plan. Make additional commits if changes are requested.
3. **Merge** — Merge to main. The pipeline applies to `ops`, then plans against `apps`.
4. **Promote** — Tag the merge commit with an `apps-deploy-*` tag. The pipeline applies to `apps`.

---

## After Every Task

At the end of every task that writes or deletes files, give the user the instructions below. Adapt the branch name and file list to what was actually changed.

If the task was a framework version update, include the lock file refresh step (marked below) between staging and committing.

---

> The Terraform files are ready. Here is what to do next to get these changes applied through the GitOps pipeline.
>
> **1. Create a feature branch and stage the changes:**
> ```
> git checkout -b <descriptive-branch-name>
> git add <list of changed files>
> ```
>
> *(Framework version update only)* **Refresh the provider lock file** before committing:
> ```
> tofu init -upgrade
> git add .terraform.lock.hcl
> ```
> This locks the provider versions required by the new framework release. Include the updated lock file in the same commit.
>
> **2. Commit and push the branch:**
> ```
> git commit -m "<short description of what changed>"
> git push -u origin <descriptive-branch-name>
> ```
> The pipeline will now run `tofu plan` against the `ops` workspace. Review the plan output before proceeding.
>
> **3. Open a pull request / merge request** and have a peer review both the file diff and the Terraform plan.
>
> **4. Merge to main** once approved. The pipeline applies to `ops`, then plans against `apps`.
>
> **5. Promote to `apps`** by tagging the merge commit:
> ```
> git tag apps-deploy-$(date +%Y%m%d%H%M%S)
> git push origin --tags
> ```
> The pipeline will apply the changes to `apps`.
