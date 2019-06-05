#!/bin/sh

set -e

if [ "$(uname -s)" == "Darwin" ]; then
    echo "${KUBECONFIG_DATA}" | base64 -D > $KUBECONFIG
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    echo "${KUBECONFIG_DATA}" | base64 -d > $KUBECONFIG
fi

if [ -s $1 ]
then
    kubectl apply -f $1
fi

rm -f $KUBECONFIG
