# Kaniko sur K8S

Utilisons maintenant Kaniko directement sur notre cluster

Pour la démonstration, nous allons héberger notre propre registry privée, directement sur le cluster, dont nous listons les images :
```sh
export CLUSTER_IP=$(kubectl get services docker-registry -o jsonpath='{.spec.clusterIP}')
curl http://$CLUSTER_IP:5000/v2/_catalog
```{{execute}}

Créons notre Dockerfile. Pour la démo, nous le stockons dans une ConfigMap K8S.
`cat << EOF > Dockerfile
FROM alpine
CMD ["/bin/echo", "\u001b[31mIt is alive and built by Kaniko on K8S!!!\u001b[m\r\n"]
EOF
`{{execute}}

`kubectl create configmap kaniko-demo --from-file=Dockerfile`{{execute}}

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
```{{execute}}


Exécutons ce pod sur K8S :
`kubectl apply -f kaniko.yaml`{{execute}}

Patientons le temps que le conteneur soit prêt et inspectons ses logs :
```
kubectl wait --for condition=containersready pod kaniko
kubectl logs -f kaniko
```{{execute}}

Interrogeons enfin notre registry privée pour valider que notre conteneur est bien disponible
```
export CLUSTER_IP=$(kubectl get services docker-registry -o jsonpath='{.spec.clusterIP}')
curl http://$CLUSTER_IP:5000/v2/_catalog
curl http://$CLUSTER_IP:5000/v2/my-super-kaniko-image/manifests/latest
```{{execute}}

Nous pouvons même l'exécuter (en ajoutant une option "insecure" pour notre registry privée) :
```
service docker restart
docker run $CLUSTER_IP:5000/my-super-kaniko-image
```{{execute}}

Mission accomplie !
