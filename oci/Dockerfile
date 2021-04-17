#
#
# Image versions
ARG BASE_BUILDER=python:3.9
ARG BASE_IMAGE=python:3.9-slim


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

# https://kubernetes.io/docs/setup/release/notes/
ARG KUBECTL_VERSION=v1.21.0

# https://github.com/kubernetes-sigs/kustomize/releases
ARG KUSTOMIZE_VERSION=v3.9.2

# https://www.terraform.io/downloads.html
ARG TERRAFORM_VERSION=0.15.0

RUN echo "KUBECTL_VERSION: ${KUBECTL_VERSION}" \
    && curl -Lo /opt/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
    && chmod +x /opt/bin/kubectl \
    && /opt/bin/kubectl version --client=true

RUN echo "KUSTOMIZE_VERSION: ${KUSTOMIZE_VERSION}" \
    && curl -LO https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz \
    && tar -xf kustomize_${KUSTOMIZE_VERSION}_linux_amd64.tar.gz \
    && mv kustomize /opt/bin/kustomize \
    && /opt/bin/kustomize version

RUN echo "TERRAFORM_VERSION: ${TERRAFORM_VERSION}" \
    && curl -LO https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /opt/bin \
    && chmod +x /opt/bin/terraform \
    && /opt/bin/terraform version

COPY oci/entrypoint oci/entrypoint_user /opt/bin/


#
#
# AWS builder
FROM builder AS aws-builder

# https://github.com/aws/aws-cli/blob/v2/CHANGELOG.rst
ARG AWS_CLI_VERSION=2.1.38

RUN mkdir -p /opt/aws/bin

RUN echo "AWS_CLI_VERSION: ${AWS_CLI_VERSION}" \
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWS_CLI_VERSION}.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install -i /opt/aws -b /opt/aws/bin \
    && /opt/aws/bin/aws --version


#
#
# GCP builder
FROM builder AS gcp-builder

# https://cloud.google.com/sdk/docs/release-notes
ARG GOOGLE_CLOUD_SDK_VERSION=336.0.0

RUN echo "GOOGLE_CLOUD_SDK_VERSION: ${GOOGLE_CLOUD_SDK_VERSION}" \
    && curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GOOGLE_CLOUD_SDK_VERSION}-linux-x86_64.tar.gz \
    && tar zxvf google-cloud-sdk-${GOOGLE_CLOUD_SDK_VERSION}-linux-x86_64.tar.gz google-cloud-sdk \
    && mv google-cloud-sdk /opt/google \
    && /opt/google/bin/gcloud --version


#
#
# Azure builder
FROM builder AS azure-builder

# https://docs.microsoft.com/en-us/cli/azure/release-notes-azure-cli?tabs=azure-cli
ARG AZURE_CLI_VERSION=2.22.0

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

# https://docs.docker.com/engine/release-notes/
ARG DOCKER_CLI_VERSION=20.10.6

RUN mkdir -p /opt/bin   

# kind requires docker client
RUN echo "DOCKER_CLI_VERSION: ${DOCKER_CLI_VERSION}" \
    && curl -O https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_CLI_VERSION}.tgz \
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
FROM final-base as dist-helper

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
