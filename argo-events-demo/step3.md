Créer une porte d'entrée html

```sh
cat << EOF > event-source.yaml
---
apiVersion: argoproj.io/v1alpha1
kind: EventSource
metadata:
  name: download-inside-out-file
spec:
  service:
    ports:
      - port: 15001
        targetPort: 15001
  webhook:
    download-inside-out-file:
      port: "15001"
      endpoint: /download-inside-out
      method: POST
EOF
```{{execute}}

`kubectl --namespace argo-events apply --filename event-source.yaml`{{execute HOST1}}

```sh
cat << EOF > ingress-inside-out-download.yaml
---
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: inside-out-download-ingress
  namespace : argo-events
spec:
  rules:
  - host: controlplane
    http:
      paths:
      - path: /download-inside-out
        backend:
          serviceName: download-inside-out-file-eventsource-svc
          servicePort: 15001
EOF
```{{execute HOST1}}

`kubectl apply -f ingress-inside-out-download.yaml`{{execute HOST1}}

Déclencher le téléchargement d'une image dans minio

```sh
cat << EOF > url-downloader.yaml
---
apiVersion: argoproj.io/v1alpha1
kind: Sensor
metadata:
  name: url-downloader
spec:
  template:
    serviceAccountName: argo-events-sa
  dependencies:
  - name: url-downloader
    eventSourceName: download-inside-out-file
    eventName: download-inside-out-file
  triggers:
  - template:
      name: url-downloader
      k8s:
        group: ""
        version: v1
        resource: pods
        operation: create
        source:
          resource:
            apiVersion: v1
            kind: Pod
            metadata:
              generateName: url-downloader-
              labels:
                app: url-downloader
            spec:
              containers:
              - name: url-downloader
                image: rg.fr-par.scw.cloud/katacoda/url-downloader:1.0.16
                args: ["tbd at runtime"]
                command: ["sh", "/run.sh"]
                env:
                 - name: MINIO_ACCESS_KEY
                   valueFrom:
                     secretKeyRef:
                       name: artifacts-minio
                       key: accesskey
                 - name: MINIO_SECRET_KEY
                   valueFrom:
                     secretKeyRef:
                       name: artifacts-minio
                       key: secretkey
                 - name: MINIO_URL
                   value: http://minio-svc.default:9000
              restartPolicy: Never
        parameters:
          - src:
              dependencyName: url-downloader
              dataKey: body.url
            dest: spec.containers.0.args.0
EOF
```{{execute HOST1}}

`kubectl --namespace argo-events apply \
    --filename url-downloader.yaml`{{execute HOST1}}

`curl -X POST \
    -H "Content-Type: application/json" \
    -d '{"url":"https://static.wikia.nocookie.net/pixar/images/0/06/Io_Sadness_standard2.jpg/revision/latest/scale-to-width-down/200"}' \
    http://controlplane/download-inside-out`{{execute HOST1}}

`./mc ls minio/input`{{execute HOST1}}

Créer un évènement minio
```sh
cat << EOF > event-minio.yaml
---
apiVersion: argoproj.io/v1alpha1
kind: EventSource
metadata:
  name: minio
spec:
  minio:
    image:
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

Analyser l'image et émettre un pubish Redis

```sh
cat << EOF > trigger-minio-tesseract.yaml
---
apiVersion: argoproj.io/v1alpha1
kind: Sensor
metadata:
  name: minio
spec:
  template:
    serviceAccountName: argo-events-sa
  dependencies:
    - name: tesseract
      eventSourceName: minio
      eventName: image
  triggers:
  - template:
      name: tesseract
      k8s:
        group: ""
        version: v1
        resource: pods
        operation: create
        source:
          resource:
            apiVersion: v1
            kind: Pod
            metadata:
              generateName: tesseract-
              labels:
                app: tesseract
            spec:
              containers:
              - name: tesseract
                image: rg.fr-par.scw.cloud/katacoda/tesseract:1.0.2
                command: ["python", "app.py"]
                args: [""]
              restartPolicy: Never
        parameters:
          - src:
              dependencyName: tesseract
              dataKey: notification.0.s3
            dest: spec.containers.0.args.0
EOF
```{{execute HOST1}}

`kubectl apply -n argo-events -f trigger-minio.yaml`{{execute HOST1}}

Créer un évènement Redis

Déclencher un appel http



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

```sh
cat << EOF > trigger-minio.yaml
---
apiVersion: argoproj.io/v1alpha1
kind: Sensor
metadata:
  name: minio
spec:
  template:
    serviceAccountName: argo-events-sa
  dependencies:
    - name: echo-payload
      eventSourceName: minio
      eventName: example
  triggers:
  - template:
      name: echo-payload
      k8s:
        group: ""
        version: v1
        resource: pods
        operation: create
        source:
          resource:
            apiVersion: v1
            kind: Pod
            metadata:
              generateName: echo-payload-
              labels:
                app: echo-payload
            spec:
              containers:
              - name: alpine
                image: alpine
                command: ["echo"]
                args: ["J'ai reçu un nouveau fichier:\n", "", ""]
              restartPolicy: Never
        # The container args from the workflow are overridden by the s3 notification key
        parameters:
          - bucket:
              dependencyName: echo-payload
              dataKey: notification.0.s3.bucket
            dest: spec.containers.0.args.1
          - file:
              dependencyName: echo-payload
              dataKey: notification.0.s3.object.key
            dest: spec.containers.0.args.2
EOF
```{{execute HOST1}}

`kubectl apply -n argo-events -f trigger-minio.yaml`{{execute HOST1}}


`kubectl apply -n argo-events -f https://raw.githubusercontent.com/argoproj/argo-events/stable/examples/sensors/minio.yaml`{{execute HOST1}}

`touch start.txt`{{execute HOST1}}

`./mc cp start.txt minio/input`{{execute HOST1}}

`kubectl --namespace argo-events logs \
    --selector app=echo-payload`{{execute HOST1}}
