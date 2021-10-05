<p align="center">
 <img src="./assets/favicon.png" alt="Kubestack, The Open Source Gitops Framework" width="25%" height="25%" />
</p>

<h1 align="center">Kubestack</h1>
<h3 align="center">The Open Source Gitops Framework</h3>

<div align="center">

[![Status](https://img.shields.io/badge/status-active-success.svg)]()
[![GitHub Issues](https://img.shields.io/github/issues/kbst/terraform-kubestack.svg)](https://github.com/kbst/terraform-kubestack/issues)
[![GitHub Pull Requests](https://img.shields.io/github/issues-pr/kbst/terraform-kubestack.svg)](https://github.com/kbst/terraform-kubestack/pulls)

</div>

<div align="center">

![GitHub Repo stars](https://img.shields.io/github/stars/kbst/terraform-kubestack?style=social)
![Twitter Follow](https://img.shields.io/twitter/follow/kubestack?style=social)

</div>


<h3 align="center"><a href="#Contributing">Join Our Contributors!</a></h3>

<div align="center">

<a href="https://github.com/kbst/terraform-kubestack/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=kbst/terraform-kubestack&max=36" />
</a>

</div>

## Introduction

[Kubestack is a Gitops framework](https://www.kubestack.com) for managed Kubernetes services based on Terraform and Kustomize.

Features:
* Provides full testability of configuration changes
* Clearly separates infrastructure and applications (`ops` & `apps` cluster pair)
* Ensures K8s cluster config, surrounding infrastructure (e.g. DNS, IPs) and cluster services (e.g. Ingress) are maintained together
* Unifies application environments across cloud providers
* Increases deployment confidance through local deployments that accurately mirror cloud deployments
* Enables a sustainable and fully automated GitOps workflow


## Getting Started

For the easiest way to get started, [visit the official Kubestack quickstart](https://www.kubestack.com/infrastructure/documentation/quickstart). This tutorial will help you get started with the Kubestack GitOps framework. It is divided into three steps.

1. Develop Locally
    * Scaffold your repository and tweak your config in a local development environment that simulates your actual cloud configuration using Kubernetes in Docker (KinD).
3. Provision Infrastructure
    * Set-up cloud prerequisites and bootstrap Kubestack's environment and clusters on your cloud provider for the first time.
4. Set-up Automation
    * Integrate CI/CD to automate changes following Kubestack's GitOps workflow.

See the [`tests`](./tests) directory for an example of how to extend this towards multi-cluster and/or multi-cloud.


## Repository Layout

This repository holds Terraform modules in directories matching the respective provider name, e.g. [`aws`](./aws), [`azurerm`](./azurerm), [`google`](./google). Additionally [`common`](./common) holds the modules that are used for all providers. Most notably the [`metadata`](./common/metadata) module that ensures a consistent naming scheme and the `cluster_services` module which integrates Kustomize into the Terraform apply.

Each cloud provider specific module directory always has a `cluster` and a `_modules` directory. The cluster module is user facing and once Kubestack is out of beta the goal is to not change the module interface unless the major version changes. The cluster module then internally uses the module in `_modules` that holds the actual implementation.

The [`quickstart`](./quickstart) directory is home to the source for the zip files that are used to bootstrap the user repositories when following the quickstart documentation.

The [`tests`](./tests) directory holds a set of happy path tests that also act as a example of how to do multiple cluster pairs across multiple clouds from one repository.


## Getting Help

**Official Documentation**  
Refer to the [official documentation](https://www.kubestack.com/framework/documentation) for a deeper dive into how to use and configure Kubetack.

**Community Help**  
If you have any questions while following the tutorial, join the [#kubestack](https://app.slack.com/client/T09NY5SBT/CMBCT7XRQ) channel on the Kubernetes community. To create an account request an [invitation](https://slack.k8s.io/).

**Professional Services**  
For organizations interested in accelerating their GitOps journey, [professional services](https://www.kubestack.com/lp/professional-services) are available.


## Contributing
Contributions to the Kubestack framework are welcome and encouraged. Before contributing, please read the [Contributing](./CONTRIBUTING.md) and [Code of Conduct](./CODE_OF_CONDUCT.md) Guidelines.

One super simple way to contribute to the success of this project is to give it a star.  

<div align="center">

![GitHub Repo stars](https://img.shields.io/github/stars/kbst/terraform-kubestack?style=social)

</div>


## Related Repositories
* [kbst/terraform-kubestack](https://github.com/kbst/terraform-kubestack) (this repository)  
    * Terraform GitOps Framework - Everything you need to build reliable automation for AKS, EKS and GKE Kubernetes clusters in one free and open-source framework.
* [kbst/kbst](https://github.com/kbst/kbst)  
    * Kubestack Framework CLI - All-in-one CLI to scaffold your Infrastructure as Code repository and deploy your entire platform stack locally for faster iteration.
* [kbst/terraform-provider-kustomization](https://github.com/kbst/terraform-provider-kustomization)  
    * Kustomize Terraform Provider - A Kubestack maintained Terraform provider for Kustomize, available in the [Terraform registry](https://registry.terraform.io/providers/kbst/kustomization/latest).
* [kbst/catalog](https://github.com/kbst/catalog)  
    * Catalog of cluster services as Kustomize bases - Continuously tested and updated Kubernetes services, installed and customizable using native Terraform syntax.

