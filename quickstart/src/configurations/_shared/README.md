# Welcome to Kubestack

This repository uses [Kubestack][1]. Kubestack is the open source GitOps framework for teams that want to automate infrastructure, not reinvent automation.

 * Infrastructure is defined using Terraform configuration
 * Cluster manifests are defined using Kustomize bases and overlays
 * Bases and overlays can be bespoke, or consumed from the [catalog][2].
 * Both infrastructure and manifests follow the Kubestack [inheritance model][3] to prevent configuration drift between the *ops* and *apps* environments
 * All changes follow the same four step process.

Full [framework documentation][4] is available online.

## Making changes

All changes to the Kubernetes cluster, supporting infrastructure and the services defined as part of the manifests in this repository follow the Kubestack [GitOps process][5]. The GitOps process ensures that changes are safely applied by first reviewing the proposed changes, then validating the changes against the *ops* environment and only then promoting the changes to be applied against the *apps* environment by setting a tag.

To accelerate the developer workflow, a [development environment][6], can be run on localhost.

 1. Change

    Make changes to the configuration in a new branch. Commit the changed configuration. Validate your changes by pushing the new branch. The pipeline runs `terraform plan` against the *ops* workspace.

    ```shell
    # checkout a new branch from master
    git checkout -b examplechange master

    # make your changes

    # commit your changes
    git commit  # write a meaningful commit message

    # push your changes
    git push origin examplechange
    ```

 1. Review

    Request a peer review of your changes. Team members review the changes and the Terraform plan. If reviewers require changes, make additional commits in the branch.

    ```shell
    # make sure you're in the correct branch
    git checkout examplechange

    # make changes required by the review

    # commit and push the required changes
    git commit  # write a meaningful commit message
    git push origin examplechange
    ```

 1. Merge

    If approved, merge your changes to master, to apply them against the *ops* environment. After applying to *ops* was successful, the pipeline runs Terraform plan against the *apps* environment.

    ```shell
    # you can merge on the commandline
    # or by merging a pull request
    git checkout master
    git merge examplechange
    git push origin master
    ```

 1. Promote

    Review the previous *apps* environment plan and tag the merge commit to promote the same changes to the *apps* environment.

    ```shell
    # make sure you're on the correct commit
    git checkout master
    git pull
    git log -1

    # if correct, tag the current commit
    # any tag prefixed with `apps-deploy-`
    # will trigger the pipeline
    git tag apps-deploy-$(date -I)-0

    # in case of multiple deploys on the same day,
    # increase the counter
    # e.g. git tag apps-deploy-2020-05-14-1
    ```

## Manual operations

In case of the automation being unavailable, upgrades requiring manual steps or in disaster recovery scenarios run Terraform and the cloud CLI locally. Kubestack provides container images bundling all dependencies to use for both automated and manual operations.

 1. Exec into container

    ```shell
    # Build the bootstrap container
    docker build -t kubestack .

    # Exec into the bootstrap container
    # add docker socket mount for local dev
    # -v /var/run/docker.sock:/var/run/docker.sock
    docker run --rm -ti \
       -v `pwd`:/infra \
       kubestack
    ```

 1. Authenticate providers

    Credentials are cached inside the `.user` directory. The directory is excluded from Git by the default `.gitignore`.

    ```shell
    # for AWS
    aws configure

    # for Azure
    az login

    # for GCP
    gcloud init
    gcloud auth application-default login
    ```

 1. Select desired environment

    ```shell
    # for ops
    terraform workspace select ops

    # or for apps
    terraform workspace select apps
    ```

 1. Run Terraform commands

    ```shell
    # run terraform init
    terraform init

    # run, e.g. terraform plan
    terraform plan
    ```

[1]: https://www.kubestack.com
[2]: https://www.kubestack.com/catalog
[3]: https://www.kubestack.com/framework/documentation/inheritance-model
[4]: https://www.kubestack.com/framework/documentation
[5]: https://www.kubestack.com/framework/documentation/gitops-process
[6]: https://www.kubestack.com/framework/documentation/tutorial-build-local-lab
