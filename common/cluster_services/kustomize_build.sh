#!/bin/sh

set -e

eval "$(jq -r '@sh "BUILD_PATH=\(.build_path) OUTPUT_PATH=\(.output_path) OUTPUT_FILE=\(.output_file)"')"

mkdir -p $OUTPUT_PATH
kustomize build -o $OUTPUT_PATH/$OUTPUT_FILE $BUILD_PATH

CHECKSUM="$(sha512sum $OUTPUT_PATH/$OUTPUT_FILE)"

jq -n --arg checksum "$CHECKSUM" '{"checksum":$checksum}'
