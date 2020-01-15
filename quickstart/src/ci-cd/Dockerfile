#
#
# Build
FROM python:2.7-slim AS builder

RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    gcc \
    unzip \
    python-virtualenv \
    libffi-dev

RUN mkdir -p /opt/bin

# Default versions
ARG KUBECTL_VERSION=v1.16.3
ARG KUSTOMIZE_VERSION=v3.4.0
ARG TERRAFORM_VERSION=0.12.19
ARG TERRAFORM_PROVIDER_KUSTOMIZE_VERSION=v0.1.0-beta.0
ARG AWS_IAM_AUTHENTICATOR_VERSION=0.4.0
ARG GOOGLE_CLOUD_SDK_VERSION=272.0.0
ARG AZURE_CLI_VERSION=2.0.77

# Common dependencies
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
    && curl -LO https://github.com/kbst/terraform-provider-kustomize/releases/download/v0.1.0-beta.0/terraform-provider-kustomization-${TERRAFORM_PROVIDER_KUSTOMIZE_VERSION}-linux-amd64 \
    && mv terraform-provider-kustomization-${TERRAFORM_PROVIDER_KUSTOMIZE_VERSION}-linux-amd64 /opt/bin/terraform-provider-kustomization \
    && chmod +x /opt/bin/terraform-provider-kustomization

# AWS specific dependencies
RUN echo "AWS_IAM_AUTHENTICATOR_VERSION: ${AWS_IAM_AUTHENTICATOR_VERSION}" \
    && curl -Lo /opt/bin/aws-iam-authenticator https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v${AWS_IAM_AUTHENTICATOR_VERSION}/aws-iam-authenticator_${AWS_IAM_AUTHENTICATOR_VERSION}_linux_amd64 \
    && chmod +x /opt/bin/aws-iam-authenticator \
    && /opt/bin/aws-iam-authenticator

RUN echo "AWS_CLI_VERSION: N/A" \
    && curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip" \
    && unzip awscli-bundle.zip \
    && ./awscli-bundle/install -i /opt/aws -b /opt/bin/aws \
    && /opt/bin/aws --version

# Google specific dependencies
RUN echo "GOOGLE_CLOUD_SDK_VERSION: ${GOOGLE_CLOUD_SDK_VERSION}" \
    && curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GOOGLE_CLOUD_SDK_VERSION}-linux-x86_64.tar.gz \
    && tar zxvf google-cloud-sdk-${GOOGLE_CLOUD_SDK_VERSION}-linux-x86_64.tar.gz google-cloud-sdk \
    && mv google-cloud-sdk /opt/google-cloud-sdk \
    && /opt/google-cloud-sdk/bin/gcloud --version

# Azure specific dependencies
RUN echo "AZURE_CLI_VERSION: ${AZURE_CLI_VERSION}" \
    && virtualenv /opt/azure/ \
    && /opt/azure/bin/pip install --no-cache-dir \
        "urllib3<1.25,>=1.21.1" \
        azure-cli==${AZURE_CLI_VERSION} \
        azure-nspkg \
        azure-mgmt-nspkg \
    && echo '#!/usr/bin/env bash\n/opt/azure/bin/python -m azure.cli "$@"' \
        > /opt/bin/az \
    && chmod +x /opt/bin/az \
    && /opt/bin/az --version

COPY nss-wrapper /opt/bin/nss-wrapper

#
#
# Final
FROM python:2.7-slim

RUN apt-get update && apt-get install -y \
      ca-certificates \
      git \
      jq \
      wget \
      openssh-client \
      dnsutils \
      libnss-wrapper \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt /opt
ENV PATH=/opt/bin:/opt/google-cloud-sdk/bin:$PATH \
    HOME=/infra/.user

WORKDIR /infra

ENTRYPOINT ["/opt/bin/nss-wrapper"]
CMD bash
