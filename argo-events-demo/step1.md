`clear && kubectl exec $(kubectl get pods -l app=argo-server -o=jsonpath='{.items[0].metadata.name}') -- argo auth token && printf "\n\n"`{{execute HOST1}}


Pour commencer, nous allons installer ArgoEvents, depuis les fichiers officiels, dans son propre namespace :
`kubectl create namespace argo-events
`{{execute HOST1}}

`kubectl apply \
    --filename https://raw.githubusercontent.com/argoproj/argo-events/stable/manifests/install.yaml
`{{execute HOST1}}

# Argo Events, SA, ClusterRoles, Sensor Controller, EventBus Controller and EventSource Controller.

# View stuff

Installons aussi l'eventbus, afin de permettre la circulation des évènements au sein du système.

`kubectl --namespace argo-events apply \
    --filename https://raw.githubusercontent.com/argoproj/argo-events/stable/examples/eventbus/native.yaml
`{{execute HOST1}}

```sh
cat << EOF > event-source.yaml
---
apiVersion: argoproj.io/v1alpha1
kind: EventSource
metadata:
  name: webhook
spec:
  service:
    ports:
      - port: 15000
        targetPort: 15000
  webhook:
    notify-me:
      port: "15000"
      endpoint: /notify-me
      method: POST
EOF
```{{execute}}

`kubectl --namespace argo-events apply \
    --filename event-source.yaml`{{execute HOST1}}

`kubectl --namespace argo-events \
    get eventsources`{{execute HOST1}}


`kubectl --namespace argo-events \
    get services`{{execute HOST1}}

`kubectl --namespace argo-events \
    get pods`{{execute HOST1}}


```
cat << EOF > ingress.yaml
---
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: default-ingress
  namespace : argo-events
spec:
  rules:
  - host: controlplane
    http:
      paths:
      - path: /
        backend:
          serviceName: webhook-eventsource-svc
          servicePort: 15000
EOF
```{{execute HOST1}}

`kubectl apply -f ingress.yaml{{execute HOST1}}

`curl -X POST \
    -H "Content-Type: application/json" \
    -d '{"message":"My first message"}' \
    http://controlplane/notify-me`{{execute HOST1}}

#file
#calendar

```
cat << EOF > sensor.yaml
---
apiVersion: argoproj.io/v1alpha1
kind: Sensor
metadata:
  name: webhook
spec:
  template:
    serviceAccountName: argo-events-sa
  dependencies:
  - name: echo-payload
    eventSourceName: webhook
    eventName: notify-me
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
                args: ["J'ai reçu un nouveau message:\n", ""]
              restartPolicy: Never
        parameters:
          - src:
              dependencyName: echo-payload
              dataKey: body
            dest: spec.containers.0.args.1
EOF
```{{execute HOST1}}

`kubectl --namespace argo-events apply \
    --filename sensor.yaml`{{execute HOST1}}


`curl -X POST \
    -H "Content-Type: application/json" \
    -d '{"message":"My first message"}' \
    http://controlplane/notify-me`{{execute HOST1}}


`kubectl --namespace argo-events get pods`{{execute HOST1}}


`kubectl --namespace argo-events logs \
    --selector app=echo-payload`{{execute HOST1}}


`kubectl --namespace argo-events \
    delete pods \
    --selector app=echo-payload`{{execute HOST1}}
