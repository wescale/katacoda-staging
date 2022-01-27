#/bin/bash

export CLUSTER_IP=$(kubectl get services docker-registry -o jsonpath='{.spec.clusterIP}')
cat /etc/docker/daemon.json | jq '."insecure-registries" += ["'"$CLUSTER_IP"':5000"]' > /tmp/daemon.json && cp /tmp/daemon.json /etc/docker/daemon.json
service docker restart