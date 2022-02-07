`helm repo add minio https://charts.min.io/`{{execute HOST1}}

`helm install  --set persistence.enabled=false \
 --set buckets[0].name=input,buckets[0].policy=none,buckets[0].purge=false \
 --set rootUser=rootuser,rootPassword=rootpass123 \
--set replicas=4 \
--set resources.requests.memory=500M \
minio \
minio/minio
`{{execute HOST1}}

`export POD_NAME=$(kubectl get pods --namespace default -l "release=minio" -o jsonpath="{.items[0].metadata.name}")`{{execute HOST1}}

`kubectl port-forward $POD_NAME 9000 --namespace default &`{{execute HOST1}}

`wget https://dl.min.io/client/mc/release/linux-amd64/mc
chmod +x mc`{{execute HOST1}}

`./mc config host add minio http://localhost:9000 $(kubectl get secret --namespace default minio -o jsonpath="{.data.rootUser}" | base64 --decode) $(kubectl get secret --namespace default minio -o jsonpath="{.data.rootPassword}" | base64 --decode)`{{execute HOST1}}

`kubectl create namespace argo-events`{{execute HOST1}}

`kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-events/stable/manifests/namespace-install.yaml`{{execute HOST1}}

`kubectl apply -n argo-events -f https://raw.githubusercontent.com/argoproj/argo-events/stable/examples/eventbus/native.yaml`{{execute HOST1}}

```sh
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
```{{execute HOST1}}

`kubectl apply -n argo-events -f secret-minio.yaml`{{execute HOST1}}

```sh
cat << EOF > event-minio.yaml
---
apiVersion: argoproj.io/v1alpha1
kind: EventSource
metadata:
  name: minio
spec:
  minio:
    example:
      bucket:
        name: input
      endpoint: minio-svc.default:9000
      events:
        - s3:ObjectCreated:Put
        - s3:ObjectRemoved:Delete
      insecure: true
      accessKey:
        key: accesskey
        name: artifacts-minio
      secretKey:
        key: secretkey
        name: artifacts-minio
EOF
```{{execute HOST1}}

`kubectl apply -n argo-events -f event-minio.yaml`{{execute HOST1}}


`kubectl apply -n argo-events -f https://raw.githubusercontent.com/argoproj/argo-events/stable/examples/sensors/minio.yaml`{{execute HOST1}}

`./mc mb minio/input`{{execute HOST1}}

`touch start.txt`{{execute HOST1}}

`./mc cp minio/input start.txt`{{execute HOST1}}
