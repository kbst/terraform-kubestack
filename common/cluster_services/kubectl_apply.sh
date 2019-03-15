#!/bin/sh

set -e

echo "${KUBECONFIG_DATA}" | base64 -d > $KUBECONFIG

if [ -s $1 ]
then
    kubectl apply -f $1
fi

rm -f $KUBECONFIG
