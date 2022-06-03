# Kaniko sur K8S

Utilisons maintenant Kaniko directement sur notre cluster.

Pour la démonstration, nous allons héberger notre propre registry privée, directement sur le cluster. Vérifions les images disponibles en local :
```sh
docker images | grep my-super-kaniko-image
```{{exec}}

Créons notre Dockerfile. Pour la démo, nous le stockons dans une ConfigMap K8S.
```
cat << EOF > Dockerfile
FROM rg.fr-par.scw.cloud/katacoda/alpine:latest
CMD ["/bin/echo", "\u001b[31mIt is alive and built by Kaniko on K8S!!!\u001b[m\r\n"]
EOF
```{{exec}}

`kubectl create configmap kaniko-demo --from-file=Dockerfile`{{exec}}

Créons maintenant un pod Kaniko, qui utilise cette ConfigMap, et qui stocke l'image bâtie dans notre registry privée. On a préalablement créé un secret qui contient le login / mot de passe de la registry.

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
            "--destination=docker-registry:5000/my-super-kaniko-image:latest",
            "--skip-tls-verify"]
    volumeMounts:
      - name: kaniko-dockerfile
        mountPath: /workspace/Dockerfile
        subPath: Dockerfile
      - name: docker-config
        mountPath: /kaniko/.docker
  restartPolicy: Never
  volumes:
    - name: kaniko-dockerfile
      configMap:
        name: kaniko-demo
    - name: docker-config
      secret:
        secretName: kaniko-docker-auth
EOF
```{{exec}}


Exécutons ce pod sur K8S :
`kubectl apply -f kaniko.yaml`{{exec}}

Patientons le temps que le conteneur soit prêt et inspectons ses logs :
```
kubectl wait --timeout=90s --for condition=containersready pod kaniko
kubectl logs -f kaniko
```{{exec}}

Interrogeons enfin notre registry privée pour valider que notre conteneur est bien disponible :
```
docker login docker-registry:5000 -u login -p password
docker pull docker-registry:5000/my-super-kaniko-image:latest
```{{exec}}

Nous pouvons même l'exécuter :
```
docker run docker-registry:5000/my-super-kaniko-image
```{{exec}}

Mission accomplie !
