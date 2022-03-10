TO BE REDACTED

```sh
cat << EOF > redis.yaml
---
apiVersion: apps/v1  # API version
kind: Deployment
metadata:
  name: redis-master # Unique name for the deployment
  labels:
    app: redis       # Labels to be applied to this deployment
spec:
  selector:
    matchLabels:     # This deployment applies to the Pods matching these labels
      app: redis
      role: master
      tier: backend
  replicas: 1        # Run a single pod in the deployment
  template:          # Template for the pods that will be created by this deployment
    metadata:
      labels:        # Labels to be applied to the Pods in this deployment
        app: redis
        role: master
        tier: backend
    spec:            # Spec for the container which will be run inside the Pod.
      containers:
      - name: master
        image: redis
        resources:
          requests:
            cpu: 100m
            memory: 100Mi
        ports:
        - containerPort: 6379
---
apiVersion: v1
kind: Service
metadata:
  name: redis
spec:
  type: ClusterIP
  ports:
  - port: 6379
    targetPort: 6379
    name: client
  - port: 16379
    targetPort: 16379
    name: gossip
  selector:
    app: redis
EOF
```{{execute HOST1}}

`kubectl apply --filename redis.yaml`{{execute HOST1}}

```sh
cat << EOF > redis-event.yaml
apiVersion: argoproj.io/v1alpha1
kind: EventSource
metadata:
  name: redis
spec:
  redis:
    redis-notify:
      hostAddress: redis.default.svc:6379
      db: 0
      # Channels to subscribe to listen events.
      channels:
        - NOTIFY
EOF
```{{execute HOST1}}

`kubectl apply --namespace argo-events --filename redis-event.yaml`{{execute HOST1}}


Insérer le secret.


```sh
cat << EOF > slack-trigger.yaml
---
apiVersion: argoproj.io/v1alpha1
kind: Sensor
metadata:
  name: redis-sensor
spec:
  dependencies:
    - name: redis-notification
      eventSourceName: redis
      eventName: redis-notify
  triggers:
    - template:
        name: slack-trigger
        slack:
          channel: test-weshare
          slackToken:
            key: token
            name: slack-secret
      parameters:
        - src:
            dependencyName: redis-notification
            dataKey: body
          dest: slack.message
EOF
```{{execute HOST1}}

`kubectl apply --namespace argo-events --filename slack-trigger.yaml`{{execute HOST1}}

`kubectl exec $(kubectl get pods -l app=redis -o jsonpath="{.items[0].metadata.name}") -- redis-cli publish NOTIFY "Test de Julien"`{{execute HOST1}}
