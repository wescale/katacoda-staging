Veuillez patienter en attendant que nous installions les éléments suivants :
Nginx Ingress Controller
Argo Server

Tout d'abord, nous allons nous authentifier auprès de Argo Server. Rafraichissez la fenêtre supérieure (lien Try Again ou bouton Display Port). Exécutez la ligne ci après.

`clear && kubectl exec $(kubectl get pods -l app=argo-server -o=jsonpath='{.items[0].metadata.name}') -- argo auth token && printf "\n\n"`{{execute HOST1}}

et copiez / collez le résultat ("Bearer xxx...xxx...") dans la case du milieu  (argo auth token), puis cliquez sur login.
Fermez les deux fenêtres d'information et cliquez sur "Event Flow" (ajouter une image).
Dans la ligne de commande de droite, modifiez le namespace "undefined" pour argo-events. Validez avec entrée.

Pour commencer, nous allons installer ArgoEvents, depuis les fichiers officiels, dans son propre namespace :
`kubectl create namespace argo-events
`{{execute HOST1}}

`kubectl apply \
    --filename https://raw.githubusercontent.com/argoproj/argo-events/stable/manifests/install.yaml
`{{execute HOST1}}

# Argo Events, SA, ClusterRoles, Sensor Controller, EventBus Controller and EventSource Controller.

Installons aussi l'eventbus, afin de permettre la circulation des évènements au sein du système.

`kubectl --namespace argo-events apply \
    --filename https://raw.githubusercontent.com/argoproj/argo-events/stable/examples/eventbus/native.yaml
`{{execute HOST1}}

Il est temps de créer notre premier évènement.

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


Vous devriez voir apparaitre votre premier Event, qui est un webhook. Depuis l'interface graphique, vous pouvez accéder au descrupteur, ainsi qu'aux logs.

On peut confirmer à l'aide de la ligne de commande.

`kubectl --namespace argo-events \
    get eventsources`{{execute HOST1}}


`kubectl --namespace argo-events \
    get services`{{execute HOST1}}

`kubectl --namespace argo-events \
    get pods`{{execute HOST1}}


Nous allons exposer notre webhook via un ingress.

```sh
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

`kubectl apply -f ingress.yaml`{{execute HOST1}}

Nous pouvons maintenant envoyer des évènements à notre hook.

`curl -X POST \
    -H "Content-Type: application/json" \
    -d '{"message":"My first message"}' \
    http://controlplane/notify-me`{{execute HOST1}}

En consultant les logs de notre pod, on constate que l'évènement est reçu.
`kubectl logs -n argo-events $(kubectl --namespace argo-events get pods -l eventsource-name=webhook -o jsonpath="{.items[0].metadata.name}")`{{execute HOST1}}

#file
#calendar


Pour l'instant, cet évènement ne déclenche aucune réaction/ Pour cela, il nous faut le lien à un sensor (qui détecte ses occurences) et à ou plusieurs triggers, les actions déclenchées sur réception.

```sh
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

Dans l'interface graphique, on constate que la chaine se complète.


Renvoyons un évènement à notre webhook :

`curl -X POST \
    -H "Content-Type: application/json" \
    -d '{"message":"My first message"}' \
    http://controlplane/notify-me`{{execute HOST1}}


On constate que de nouveux pods sont créés

`kubectl --namespace argo-events get pods`{{execute HOST1}}

Et qu'ils ont correctement réagi à nos évènements.

`kubectl --namespace argo-events logs \
    --selector app=echo-payload`{{execute HOST1}}


`kubectl --namespace argo-events \
    delete pods \
    --selector app=echo-payload`{{execute HOST1}}

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

Insérer le secret.

`kubectl exec $(kubectl get pods -l app=redis -o jsonpath="{.items[0].metadata.name}") -- redis-cli publish NOTIFY "Test de Julien"`{{execute HOST1}}
