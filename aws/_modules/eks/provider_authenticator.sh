#!/bin/sh
set -e

# Extract cluster name from STDIN
eval "$(jq -r '@sh "CLUSTER_NAME=\(.cluster_name) CALLER_ID_ARN=\(.caller_id_arn) CALLER_ID_ARN_TYPE=\(.caller_id_arn_type)"')"

# Retrieve token with Heptio Authenticator
TOKEN=$(aws-iam-authenticator token -i $CLUSTER_NAME | jq -r .status.token)
if [ $CALLER_ID_ARN_TYPE = "role" ]; then
  TOKEN=$(aws-iam-authenticator token -i $CLUSTER_NAME --role $CALLER_ID_ARN | jq -r .status.token)
fi

# Output token as JSON
jq -n --arg token "$TOKEN" '{"token": $token}'
