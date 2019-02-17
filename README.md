# Terraform Kubestack

Terraform modules that implement the [Kubestack, fast path to production on Kubernetes](https://www.kubestack.com).

For the easiest way to get started with Kubestack, [try the quickstart](https://www.kubestack.com/infrastructure/documentation/quickstart).

## Development Workflow

1. Push your branch to trigger CI/CD or install `cloud-build-local` using e.g. `gcloud components install cloud-build-local` and run:

    ```
    cloud-build-local --config=cloudbuild.yaml \
      --substitutions=_QUICKSTART_BUCKET_NAME=,TAG_NAME=,BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD) \
      --dryrun=false \
      --write-workspace=_build \
      .
    ```

## Making a Release

1. Create a Git tag following semver, prefixed with `v`. E.g. `v0.1.0`
1. Push the tag to trigger CI/CD
