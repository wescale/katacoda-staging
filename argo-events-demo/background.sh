#/bin/bash

helm repo add minio https://charts.min.io/

helm install  --set persistence.enabled=false \
 --set buckets[0].name=input,buckets[0].policy=none,buckets[0].purge=false \
 --set rootUser=rootuser,rootPassword=rootpass123 \
--set replicas=4 \
--set resources.requests.memory=500M \
minio \
minio/minio

wget https://dl.min.io/client/mc/release/linux-amd64/mc
chmod +x mc

sleep 5;

cat << EOF > secret-minio.yaml
---
apiVersion: v1
data:
  accesskey: cm9vdHVzZXI=
  secretkey: cm9vdHBhc3MxMjM=
kind: Secret
metadata:
  name: artifacts-minio
  namespace: argo-events
EOF

kubectl apply -n argo-events -f secret-minio.yaml

touch /root/backgroundDone.txt
