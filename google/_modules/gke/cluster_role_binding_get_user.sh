#!/bin/sh

set -e

if [ ! -z "$GOOGLE_APPLICATION_CREDENTIALS" ]
then
    gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS
fi

USER="$(gcloud auth list --filter=status:ACTIVE --format='value(account)')"

jq -n --arg user "$USER" '{"user":$user}'
