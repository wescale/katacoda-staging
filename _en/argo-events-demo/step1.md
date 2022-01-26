Install Argo-Events
`kubectl create namespace argo-events
`{{execute}}

`kubectl apply \
    --filename https://raw.githubusercontent.com/argoproj/argo-events/stable/manifests/install.yaml
`{{execute}}

`kubectl --namespace argo-events apply \
    --filename https://raw.githubusercontent.com/argoproj/argo-events/stable/examples/eventbus/native.yaml
`{{execute}}

`cat << EOF > event-source.yaml
---
apiVersion: argoproj.io/v1alpha1
kind: EventSource
metadata:
  name: webhook
spec:
  service:
    ports:
      - port: 12000
        targetPort: 12000
  webhook:
    devops-toolkit:
      port: "12000"
      endpoint: /devops-toolkit
      method: POST
EOF
`{{execute}}

First, we build it :
`docker build -t my-super-image .`{{execute}}

Then, we run it :
`docker run my-super-image`{{execute}}

Yeah !
