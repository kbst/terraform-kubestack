# Kubestack AGENTS.md file for framework development
** for framework usage separate AGENTS.md files are provided as part of the quickstarts **

Kubestack is an OpenTofu/Terraform framework for platform engineering teams building Kubernetes-based platforms.
It provides re-usable modules to manage clusters, node-pools and platform services from a unified configuration using a GitOps workflow.

 * cluster modules provision managed Kubernetes offerings from cloud providers and all their respective infrastructure requirements
 * node-pool modules are used to configure the node pools attached to the respective cluster
 * platform service modules install services that need to exist on clusters before applications can be deployed

Inheritance-based configuration to avoid drift between environments, and keeping infrastructure and application environments separate to avoid blockers between infrastructure and application changes are cornerstones of Kubestack's design.

Any Kubestack framework module aims to provide a unified developer experience and no surprises infrastructure automation.

## Repository and module layout

 * the repository root has directories for `common/` modules shared between all providers, and provider-specific module directories
 * provider-specific module directory names follow the OpenTofu/Terraform provider name for that cloud, e.g. `aws`, `azurerm` or `google`
 * in each provider-specific module directory there is a `cluster/` directory holding the cluster module and its node-pool submodule in the `cluster/node-pool` directory
 * the configuration and metadata module calls, as well as the main resource for the respective module (cluster resource for cluster modules, node-pool resource for node-pool modules) must always be in the file `main.tf`
 * every cluster provisioned by Kubestack must have a default node pool; the default node pool must be provisioned by calling the cluster's node-pool submodule in a `node_pool.tf` file, with the following exceptions:
   * if the cloud provider mandates a built-in default node pool that cannot be disabled (e.g. AKS), use the provider's built-in default node pool instead; `node_pool.tf` is not required in this case
   * if the cloud provider includes a default node pool that can be disabled (e.g. GKE), it must be disabled and the node-pool submodule must still be used in `node_pool.tf`
 * kubeconfig and default ingress related code must be in `kubeconfig.tf` and `ingress.tf` for all cluster modules
 * outputs must be defined in `outputs.tf`
 * moved blocks must be in `moved.tf`
 * variables must be defined in `variables.tf`
 * a data source used by only one resource must be placed directly in front of that resource; if a data source is used by multiple resources or supports conditional logic, it must be placed in a separate `data_sources.tf` file
 * additional files like `vpc.tf`, `roles.tf`, `launch_template.tf` etc. may be created if grouping resources into separate files improves maintainability

### Variables and Outputs
 * all Kubestack modules share a common set of variables and outputs per module type
 * configuration inheritance variables:
   * every module written for the Kubestack framework must define both a `configuration` variable of type `map(object)` and a `configuration_base_key` variable of type `string`; the `configuration_base_key` variable defaults to `apps` so it is optional for users of the module, but both variables must always be defined when writing framework modules
   * the map key of `configuration` is the environment name and the object defines the module and provider-specific configuration attributes
   * all configuration object attributes must be marked optional and must not define a default, because the inheritance implementation relies on unset attributes being null to determine whether to inherit or overwrite an attribute for the current environment
   * inside the module the configuration module must be called, passing in `var.configuration` and `var.configuration_base_key`; the resulting merged config for the current environment (`terraform.workspace`) must be made available as `local.cfg`
   * `local.cfg.<key>` must be used as the input to any resource that requires a value from the module's configuration
   * Kubestack prefers upstream defaults by passing `null` to resource arguments
   * if a default must be set, use the `try(coalesce(<key>, null), <default>)` pattern; this ensures that any nested key error or a null value from coalesce is caught by try, so the default only has to be specified once
 * cluster module outputs:
   * `cluster`: all attributes the cluster resource returns
   * `current_config`: the merged output of the configuration module (`local.cfg`)
   * `current_metadata`: the entire output of the metadata module
   * `kubeconfig`: the yaml encoded kubeconfig for the provisioned cluster; the output is used to configure the provider for platform service modules to be installed on the cluster
   * do not add additional outputs unless there is no alternative; exceptions must not be taken lightly to avoid module user experience drifting apart between providers
 * node-pool module variables and outputs:
   * in addition to the common `configuration` and `configuration_base_key` variables, node pools also require `cluster` and `cluster_metadata` variables that expect the data from the cluster's corresponding `cluster` and `current_metadata` outputs
   * do not add additional variables or outputs unless there is no alternative; the `aws/cluster` and `aws/cluster/node-pool` modules are an example of a case where additional variables were necessary

## Testing instructions
 * testing the Kubestack framework is expensive because real cloud infrastructure has to be created and cleanly deprovisioned as part of the integration tests
 * the multi-cloud platform configuration for the tests can be found in the `tests/` directory
 * a Makefile provides common development targets to run locally and ensures they are run in a container with the correct dependencies and correct working directory
 * never run OpenTofu/Terraform commands manually outside one of the specified make targets
 * `make validate` is safe to run at any time and must be run to validate any changes
 * never run `make test` or `make cleanup` unless explicitly asked to by the user
 * the `common/configuration` and `common/metadata` modules have unit tests; after making any changes to these modules, run `tofu test` inside the respective module directory
