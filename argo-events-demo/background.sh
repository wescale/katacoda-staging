#/bin/bash
helm repo add minio https://charts.min.io/ >> /root/background.log

helm repo update >> /root/background.log

sleep 5;

helm install  --set persistence.enabled=false \
 --set rootUser=rootuser,rootPassword=rootpass123 \
--set replicas=4 \
--set resources.requests.memory=500M \
minio \
minio/minio >> /root/background.log

wget https://dl.min.io/client/mc/release/linux-amd64/mc >> /root/background.log
chmod +x mc >> /root/background.log

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

kubectl apply -n argo-events -f secret-minio.yaml >> /root/background.log
