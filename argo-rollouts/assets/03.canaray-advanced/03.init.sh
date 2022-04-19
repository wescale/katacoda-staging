#/bin/bash

# init script for step 3 - canary-advanced

# modify /etc/hosts to add links to the cluster
IP_CLUSTER=$(grep -Po "(?<=server: https://)[0-9]{1-3}\.[0-9]{1-3}\.[0-9]{1-3}\.[0-9]{1-3}" ~/.kube/config)
echo "${IP_CLUSTER} argo-rollouts.kube" >> /etc/hosts
echo "${IP_CLUSTER} argo-rollouts-preview.kube" >> /etc/hosts

