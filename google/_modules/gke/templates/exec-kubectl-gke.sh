#!/bin/sh
gcloud config config-helper --format=json "$@" | jq '{"apiVersion": "client.authentication.k8s.io/v1beta1", "kind": "ExecCredential", "status": {"token": .credential.access_token, "expirationTimestamp": .credential.token_expiry}}'

# source: https://github.com/jglick/gke-exec-credential
