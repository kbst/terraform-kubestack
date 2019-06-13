# Kubestack Gitops Framework

[Kubestack is a Gitops framework](https://www.kubestack.com) for managed Kubernetes services based on Terraform and Kustomize. It is designed to:

 * provide full testability by clearly separating infrastructure and application environments through the ops- and apps-cluster pair
 * ensure K8s cluster config, surrounding infrastructure (e.g. DNS, IPs) and cluster services (e.g. Ingress) are maintained together
 * unify application environments across cloud providers
 * enable a sustainable and fully automated Gitops workflow

For the easiest way to get started with Kubestack, [visit the quickstart](https://www.kubestack.com/infrastructure/documentation/quickstart). The quickstart will bootstrap a user repository and a first cluster pair. See the `tests` for an example of how to extend this towards multi-cluster and/or multi-cloud.

## Repository Layout

This repository holds Terraform modules in directories matching the respective provider name, e.g. `aws`, `azurerm`, `google`. Additionally `common` holds the modules that are used for all providers. Most notably the `metadata` module that ensures a consistent naming scheme and the `cluster_services` module which integrates Kustomize into the Terraform apply.

Each cloud provider specific module directory always has a `cluster` and a `_modules` directory. The cluster module is user facing and once Kubestack is out of beta the goal is to not change the module interface unless the major version changes. The cluster module then internally uses the module in `_modules` that holds the actual implementation.

The `quickstart` directory is home to the source for the zip files that are used to bootstrap the user repositories when following the quickstart documentation.

`tests` holds a set of happy path tests that also act as a example of how to do multiple cluster pairs across multiple clouds from one repository.

## Development Workflow

To build a set of quickstart zip files push your branch to trigger CI/CD or install `cloud-build-local` using e.g. `gcloud components install cloud-build-local` and run:

    ```
    rm -rf _build && cloud-build-local \
        --substitutions=_QUICKSTART_BUCKET_NAME=,TAG_NAME=,BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD) \
        --dryrun=false \
        --write-workspace=_build \
        .
    ```

## Making a Release

1. Create a Git tag following semver, prefixed with `v`. E.g. `v0.1.0`
1. Push the tag to trigger CI/CD
