#!/bin/bash 
eval "$(jq -r '@sh "GROUP=\(.resource_group)"')"
OUTPUT=$(az network nsg list -g "$GROUP" --query [].name -o tsv | grep aks | head -n 1)
jq -n --arg output "$OUTPUT" '{"output":$output}'
