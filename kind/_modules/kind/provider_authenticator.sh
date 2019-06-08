#!/bin/sh
set -e

# Extract cluster name from STDIN
eval "$(jq -r '@sh "CLUSTER_NAME=\(.cluster_name)"')"

# Retrieve path to kubeconfig from kind
KUBECONFIG_PATH=$(kind get kubeconfig-path --name $CLUSTER_NAME)

# Output path to kubeconfig file as JSON
jq -n --arg kubeconfig_path "$KUBECONFIG_PATH" '{"kubeconfig_path": $kubeconfig_path}'
