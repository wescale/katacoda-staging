# Kaniko sur K8S

Utilisons maintenant Kaniko directement sur notre cluster

Pour la démonstration, nous allons héberger notre propre registry privée, directement sur le cluster, dont nous listons les images :
```sh
docker login docker-registry:5000 -u login -p password
docker images ls
```{{execute HOST1}}

Créons notre Dockerfile. Pour la démo, nous le stockons dans une ConfigMap K8S.
`cat << EOF > Dockerfile
FROM alpine
CMD ["/bin/echo", "\u001b[31mIt is alive and built by Kaniko on K8S!!!\u001b[m\r\n"]
EOF
`{{execute HOST1}}

`kubectl create configmap kaniko-demo --from-file=Dockerfile`{{execute HOST1}}

Créons maintenant un pod Kaniko, qui utilise cette ConfigMap, et qui stocke l'image batie dans notre registry privée.

```sh
cat << EOF > kaniko.yaml
---
apiVersion: v1
kind: Pod
metadata:
  name: kaniko
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:debug
    args: ["--dockerfile=/workspace/Dockerfile",
            "--context=dir://workspace",
            "--destination=docker-registry.default.svc:5000/my-super-kaniko-image:latest",
            "--insecure"]
    volumeMounts:
      - name: kaniko-dockerfile
        mountPath: /workspace/Dockerfile
        subPath: Dockerfile
  restartPolicy: Never
  volumes:
    - name: kaniko-dockerfile
      configMap:
        name: kaniko-demo
EOF
```{{execute HOST2}}


Exécutons ce pod sur K8S :
`kubectl apply -f kaniko.yaml`{{execute HOST2}}

Patientons le temps que le conteneur soit prêt et inspectons ses logs :
```
kubectl wait --timeout=90s --for condition=containersready pod kaniko
kubectl logs -f kaniko
```{{execute HOST1}}

Interrogeons enfin notre registry privée pour valider que notre conteneur est bien disponible
```
docker images ls
```{{execute HOST1}}

Nous pouvons même l'exécuter :
```
docker run my-super-kaniko-image
```{{execute HOST1}}

Mission accomplie !
