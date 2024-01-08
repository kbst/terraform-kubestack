#
#
# Image versions
ARG BASE_BUILDER=python:3.11
ARG BASE_IMAGE=python:3.11-slim


#
#
# Base builder
FROM ${BASE_BUILDER} AS builder

RUN apt-get update && apt-get install -y \
    curl \
    gcc \
    unzip

RUN mkdir -p /opt/bin


#
#
# Common builder
FROM builder AS common-builder

ARG TARGETARCH

# https://github.com/kubernetes/kubernetes/releases
ARG KUBECTL_VERSION=v1.28.5

# https://github.com/kubernetes-sigs/kustomize/releases
ARG KUSTOMIZE_VERSION=v5.3.0

# https://www.terraform.io/downloads.html
# 1.5.x is the last OSS Terraform
# do not update major or minor!
ARG TERRAFORM_VERSION=1.5.7

RUN echo "KUBECTL_VERSION: ${KUBECTL_VERSION}" \
    && curl -LO https://dl.k8s.io/${KUBECTL_VERSION}/kubernetes-client-linux-${TARGETARCH}.tar.gz \
    && tar -xf kubernetes-client-linux-${TARGETARCH}.tar.gz \
    && mv kubernetes/client/bin/kubectl* /opt/bin/ \
    && chmod +x /opt/bin/kubectl* \
    && /opt/bin/kubectl version --client=true

RUN echo "KUSTOMIZE_VERSION: ${KUSTOMIZE_VERSION}" \
    && curl -LO https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_${TARGETARCH}.tar.gz \
    && tar -xf kustomize_${KUSTOMIZE_VERSION}_linux_${TARGETARCH}.tar.gz \
    && mv kustomize /opt/bin/kustomize \
    && /opt/bin/kustomize version

RUN echo "TERRAFORM_VERSION: ${TERRAFORM_VERSION}" \
    && curl -LO https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${TARGETARCH}.zip \
    && unzip terraform_${TERRAFORM_VERSION}_linux_${TARGETARCH}.zip -d /opt/bin \
    && chmod +x /opt/bin/terraform \
    && /opt/bin/terraform version

COPY oci/entrypoint oci/entrypoint_user /opt/bin/


#
#
# AWS builder
FROM builder AS aws-builder

ARG TARGETARCH

# https://github.com/aws/aws-cli/blob/v2/CHANGELOG.rst
ARG AWS_CLI_VERSION=2.15.8

RUN mkdir -p /opt/aws/bin

RUN echo "AWS_CLI_VERSION: ${AWS_CLI_VERSION}" \
    && arch=`echo ${TARGETARCH} | sed -e 's/amd64/x86_64/' -e 's/arm64/aarch64/'` \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-${arch}-${AWS_CLI_VERSION}.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install -i /opt/aws -b /opt/aws/bin \
    && /opt/aws/bin/aws --version


#
#
# GCP builder
FROM builder AS gcp-builder

ARG TARGETARCH

# https://cloud.google.com/sdk/docs/release-notes
ARG GOOGLE_CLOUD_SDK_VERSION=458.0.1

RUN echo "GOOGLE_CLOUD_SDK_VERSION: ${GOOGLE_CLOUD_SDK_VERSION}" \
    && arch=`echo ${TARGETARCH} | sed -e 's/amd64/x86_64/' -e 's/arm64/arm/'` \
    && curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GOOGLE_CLOUD_SDK_VERSION}-linux-${arch}.tar.gz \
    && tar zxvf google-cloud-sdk-${GOOGLE_CLOUD_SDK_VERSION}-linux-${arch}.tar.gz google-cloud-sdk \
    && mv google-cloud-sdk /opt/google \
    && /opt/google/bin/gcloud --version

RUN /opt/google/bin/gcloud components install gke-gcloud-auth-plugin


#
#
# Azure builder
FROM builder AS azure-builder

# https://docs.microsoft.com/en-us/cli/azure/release-notes-azure-cli?tabs=azure-cli
ARG AZURE_CLI_VERSION=2.55.0

RUN apt-get update && apt-get install -y \
    libffi-dev

RUN echo "AZURE_CLI_VERSION: ${AZURE_CLI_VERSION}" \
    && python -m venv /opt/azure/ \
    && /opt/azure/bin/pip install --no-cache-dir \
    azure-cli==${AZURE_CLI_VERSION} \
    && echo '#!/usr/bin/env bash\n/opt/azure/bin/python -m azure.cli "$@"' \
    > /opt/bin/az \
    && chmod +x /opt/bin/az \
    && /opt/bin/az --version


#
#
# KinD builder
FROM builder as kind-builder

ARG TARGETARCH

# https://docs.docker.com/engine/release-notes/
ARG DOCKER_CLI_VERSION=24.0.7

RUN mkdir -p /opt/bin

# kind requires docker client
RUN echo "DOCKER_CLI_VERSION: ${DOCKER_CLI_VERSION}" \
    && arch=`echo ${TARGETARCH} | sed -e 's/amd64/x86_64/' -e 's/arm64/aarch64/'` \
    && curl -O https://download.docker.com/linux/static/stable/${arch}/docker-${DOCKER_CLI_VERSION}.tgz \
    && tar zxvf docker-${DOCKER_CLI_VERSION}.tgz -C . docker/docker \
    && mv docker/docker /opt/bin/docker \
    && /opt/bin/docker --help


#
#
# Final base
FROM ${BASE_IMAGE} AS final-base

RUN apt-get update && apt-get install -y \
    ca-certificates \
    git \
    jq \
    wget \
    openssh-client \
    dnsutils \
    unzip \
    groff \
    less \
    && rm -rf /var/lib/apt/lists/*

ENV HOME=/infra/.user

# Common
COPY --from=common-builder /opt/bin /opt/bin
ENV PATH=/opt/bin:$PATH

WORKDIR /infra

ENTRYPOINT ["/opt/bin/entrypoint"]
CMD bash


#
#
# Build starters and provider cache
FROM final-base as dist-helper-build

COPY common /common

# Run inheritance module tests
RUN cd /common/configuration &&\
    terraform test

# Run metadata module tests
RUN cd /common/metadata &&\
    terraform test

ARG GIT_SHA=master
ARG GIT_REF=refs/heads/master

COPY quickstart /quickstart
WORKDIR /quickstart

# Build starters
RUN cd build_artifacts &&\
    pip install --no-cache-dir pipenv &&\
    pipenv install

ENV GIT_SHA=${GIT_SHA} \
    GIT_REF=${GIT_REF}
RUN cd build_artifacts &&\
    pipenv run python dist.py dist

# Run terraform init for each starter
RUN mkdir -p /terraform/plugin-cache
ENV TF_PLUGIN_CACHE_DIR=/terraform/plugin-cache
RUN set -e &&\
    for name in `ls /quickstart/_dist/`; do \
    if [ -d /quickstart/_dist/$name ]; then \
    cd /quickstart/_dist/$name &&\
    terraform init --upgrade &&\
    rm -rf .terraform; \
    fi; \
    done

RUN cd build_artifacts &&\
    pipenv run python dist.py compress

#
#
# Dist artifacts
FROM alpine as dist-helper

COPY --from=dist-helper-build /quickstart/_dist /quickstart/_dist


#
#
# AWS variant
FROM final-base AS eks

# AWS
COPY --from=aws-builder /opt/aws /opt/aws
ENV PATH=$PATH:/opt/aws/bin


#
#
# GCP variant
FROM final-base AS gke

# GCP
COPY --from=gcp-builder /opt/google /opt/google
ENV PATH=$PATH:/opt/google/bin


#
#
# Azure variant
FROM final-base AS aks

# Azure
COPY --from=azure-builder /opt/azure /opt/azure
ENV PATH=$PATH:/opt/azure/bin


#
#
# KinD variant
FROM final-base AS kind

# KinD provider
COPY --from=kind-builder /opt/bin /opt/bin


#
#
# Default (multi-cloud) variant
FROM final-base AS multi-cloud

# AWS
COPY --from=aws-builder /opt/aws /opt/aws
ENV PATH=$PATH:/opt/aws/bin

# GCP
COPY --from=gcp-builder /opt/google /opt/google
ENV PATH=$PATH:/opt/google/bin

# Azure
COPY --from=azure-builder /opt/azure /opt/azure
ENV PATH=$PATH:/opt/azure/bin
