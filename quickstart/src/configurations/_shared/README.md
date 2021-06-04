# Welcome to Kubestack

This repository uses [Kubestack][1]. Kubestack is the open source GitOps framework for teams that want to automate infrastructure, not reinvent automation.

- Cluster infrastructure and cluster services are defined using Terraform modules.
- Popular cluster services are available from the Terraform module [catalog][2].
- Both cluster and cluster service modules follow the Kubestack [inheritance model][3] to prevent configuration drift between environments.
- All changes follow the same four-step process.

Full [framework documentation][4] is available online.

## Making changes

To make changes to the Kubernetes cluster(s), supporting infrastructure or the Kubernetes services defined in this repository follow the Kubestack [GitOps process][5]. The GitOps process ensures that changes are safely applied by first reviewing the proposed changes, then validating the changes against the _ops_ environment and finally promoting the changes to be applied against the _apps_ environment by setting a tag.

To accelerate the developer workflow an auto-updating [development environment][6] can be run on localhost using the `kbst local apply` command.

1. Change

   Make changes to the configuration in a new branch. Commit the changed configuration and push your branch. The pipeline runs `terraform plan` against the _ops_ workspace.

   ```shell
   # checkout a new branch from main
   git checkout -b examplechange main

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

   If approved, merge your changes to main, to apply them against the _ops_ environment. After applying to _ops_ was successful, the pipeline runs Terraform plan against the _apps_ environment.

   ```shell
   # you can merge on the commandline
   # or by merging a pull request
   git checkout main
   git merge examplechange
   git push origin main
   ```

1. Promote

   Review the previous _apps_ environment plan and tag the merge commit to promote the same changes to the _apps_ environment.

   ```shell
   # make sure you're on the correct commit
   git checkout main
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
   # Build the container image
   docker build -t kubestack .

   # Exec into the container image
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
[6]: https://www.kubestack.com/framework/documentation/tutorial-develop-locally#provision-local-clusters
