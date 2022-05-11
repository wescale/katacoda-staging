#!/bin/bash

ec=0

if ! kubectl get Rollouts; then
    echo "Install the Rollouts CRD in the server"
    ec=1
fi

if ! kubectl argo rollouts version; then
    echo "Install the kubectl plugin for argo rollouts"
    ec=1
fi

if [[ $ec == 1 ]]; then
    echo "done"
    exit 0
fi

exit 1