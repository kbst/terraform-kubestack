<p align="center">
 <img src="./assets/favicon.png" alt="Kubestack, The Open Source Gitops Framework" width="25%" height="25%" />
</p>

<h1 align="center">Kubestack</h1>
<h3 align="center">The Open Source Terraform framework for Kubernetes Platform Engineering</h3>

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

[Kubestack is a Terraform framework for Kubernetes Platform Engineering](https://www.kubestack.com) teams to define the entire cloud native stack in one Terraform code base and continuously evolve the platform safely through GitOps.

### Highlights

* [Convention over configuration platform engineering framework](https://www.kubestack.com/framework/documentation/) that makes the power of platforms accessible to your whole engineering team
* [Platform architecture](https://www.kubestack.com/framework/documentation/platform-architecture/) and [GitOps workflow](https://www.kubestack.com/framework/documentation/gitops-process/) enabling all team members to safely iterate while protecting your application environments
* [Extendable, future-proof, low-maintenance Terraform code base](https://www.kubestack.com/framework/documentation/extending-kubestack/) and robust automation even for complex Kubernetes platforms

## Getting Started

For the easiest way to get started, [follow the Kubestack tutorial](https://www.kubestack.com/framework/tutorial/).
The tutorial will help you get started with the Kubestack framework and build a Kubernetes platform application teams love.

## Getting Help

**Official Documentation**  
Refer to the [official documentation](https://www.kubestack.com/framework/documentation) for a deeper dive into how to use and configure Kubestack.

**Community Help**  
If you have any questions while following the tutorial, join the [#kubestack](https://app.slack.com/client/T09NY5SBT/CMBCT7XRQ) channel on the Kubernetes community. To create an account request an [invitation](https://slack.k8s.io/).

## Contributing

This repository holds Terraform modules in directories matching the respective provider name, e.g. [`aws`](./aws), [`azurerm`](./azurerm), [`google`](./google). Additionally [`common`](./common) holds the modules that are used for all providers.
Most notably the [`metadata`](./common/metadata) module that ensures a consistent naming scheme and the `cluster_services` module which integrates Kustomize into the Terraform apply.

Each cloud provider specific module directory always has a `cluster` and `_modules` directories.
The cluster module is user facing and once Kubestack is out of beta the goal is to not change the module interface unless the major version changes.
The cluster module then internally uses the module in `_modules` that holds the actual implementation.

The [`quickstart`](./quickstart) directory is home to the source for the zip files that are used to bootstrap the user repositories when following the tutorial.

The [`tests`](./tests) directory holds a set of happy path tests.

Contributions to the Kubestack framework are welcome and encouraged. Before contributing, please read the [Contributing](./CONTRIBUTING.md) and [Code of Conduct](./CODE_OF_CONDUCT.md) Guidelines.

One super simple way to contribute to the success of this project is to give it a star.  

<div align="center">

![GitHub Repo stars](https://img.shields.io/github/stars/kbst/terraform-kubestack?style=social)

</div>

## Kubestack Repositories

* [kbst/terraform-kubestack](https://github.com/kbst/terraform-kubestack) (this repository)  
  * [Terraform framework for Kubernetes Platform Engineering](https://www.kubestack.com/) teams - Define your entire cloud native Kubernetes stack in one Terraform code base and continuously evolve the platform safely through GitOps.
* [kbst/kbst](https://github.com/kbst/kbst)  
  * Kubestack CLI `kbst` - The CLI helps you scaffold the Terraform code that defines the clusters, node pools or services of your platform. The CLI works on local files only, you can see any change it makes with git status.
* [kbst/terraform-provider-kustomization](https://github.com/kbst/terraform-provider-kustomization)  
  * Kustomize Terraform Provider - A Kubestack maintained Terraform provider for Kustomize, available in the [Terraform registry](https://registry.terraform.io/providers/kbst/kustomization/latest).
* [kbst/catalog](https://github.com/kbst/catalog)  
  * Catalog of Terraform modules for Kubernetes platforms - The [Kubestack Terraform modules](https://www.kubestack.com/catalog/) make it easy for platform engineering teams to deliver common platform features in production ready configurations.
