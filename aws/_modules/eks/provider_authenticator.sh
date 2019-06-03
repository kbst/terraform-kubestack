#!/bin/sh
set -e

# Extract cluster name from STDIN
eval "$(jq -r '@sh "CLUSTER_NAME=\(.cluster_name) ROLE_ARN=\(.role_arn)"')"

# Retrieve token with Heptio Authenticator
TOKEN=$(aws-iam-authenticator token -i $CLUSTER_NAME --role $ROLE_ARN | jq -r .status.token)

# Output token as JSON
jq -n --arg token "$TOKEN" '{"token": $token}'
