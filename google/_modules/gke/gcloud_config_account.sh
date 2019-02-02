#!/bin/sh

set -e

USER="$(gcloud config get-value account)"

jq -n --arg user "$USER" '{"user":$user}'
