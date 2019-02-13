#!/bin/sh

set -e

if [ -s $1 ]
then
    kubectl apply -f $1
fi
