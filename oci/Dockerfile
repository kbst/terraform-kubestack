#
#
# Image versions
ARG BASE_BUILDER=python:3.8
ARG BASE_IMAGE=python:3.8-slim


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

ARG KUBECTL_VERSION=v1.18.1
ARG KUSTOMIZE_VERSION=v3.5.4
ARG TERRAFORM_VERSION=0.12.24
ARG TERRAFORM_PROVIDER_KUSTOMIZE_VERSION=v0.1.0-beta.3

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

RUN echo "TERRAFORM_PROVIDER_KUSTOMIZE_VERSION: ${TERRAFORM_PROVIDER_KUSTOMIZE_VERSION}" \
    && curl -LO https://github.com/kbst/terraform-provider-kustomize/releases/download/${TERRAFORM_PROVIDER_KUSTOMIZE_VERSION}/terraform-provider-kustomization-${TERRAFORM_PROVIDER_KUSTOMIZE_VERSION}-linux-amd64 \
    && mv terraform-provider-kustomization-${TERRAFORM_PROVIDER_KUSTOMIZE_VERSION}-linux-amd64 /opt/bin/terraform-provider-kustomization \
    && chmod +x /opt/bin/terraform-provider-kustomization

COPY entrypoint /opt/bin/entrypoint


#
#
# AWS builder
FROM builder AS aws-builder

ARG AWS_IAM_AUTHENTICATOR_VERSION=0.5.0

RUN mkdir -p /opt/aws/bin

RUN echo "AWS_IAM_AUTHENTICATOR_VERSION: ${AWS_IAM_AUTHENTICATOR_VERSION}" \
    && curl -Lo /opt/aws/bin/aws-iam-authenticator https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v${AWS_IAM_AUTHENTICATOR_VERSION}/aws-iam-authenticator_${AWS_IAM_AUTHENTICATOR_VERSION}_linux_amd64 \
    && chmod +x /opt/aws/bin/aws-iam-authenticator \
    && /opt/aws/bin/aws-iam-authenticator

RUN echo "AWS_CLI_VERSION: N/A" \
    && curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip" \
    && unzip awscli-bundle.zip \
    && ./awscli-bundle/install -i /opt/aws \
    && /opt/aws/bin/aws --version


#
#
# GCP builder
FROM builder AS gcp-builder

ARG GOOGLE_CLOUD_SDK_VERSION=289.0.0

RUN echo "GOOGLE_CLOUD_SDK_VERSION: ${GOOGLE_CLOUD_SDK_VERSION}" \
    && curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GOOGLE_CLOUD_SDK_VERSION}-linux-x86_64.tar.gz \
    && tar zxvf google-cloud-sdk-${GOOGLE_CLOUD_SDK_VERSION}-linux-x86_64.tar.gz google-cloud-sdk \
    && mv google-cloud-sdk /opt/google \
    && /opt/google/bin/gcloud --version


#
#
# Azure builder
FROM builder AS azure-builder

ARG AZURE_CLI_VERSION=2.3.1

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
# Final base
FROM ${BASE_IMAGE} AS final-base

RUN apt-get update && apt-get install -y \
      ca-certificates \
      git \
      jq \
      wget \
      openssh-client \
      dnsutils \
      libnss-wrapper \
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
