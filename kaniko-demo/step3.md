# Une méthode dangereuse, mais qui fonctionne

Le démon Docker tourne actuellement sur les noeuds du cluster K8S. La CLI Docker interagit avec ce démon via une Socket. Si nous récupérons cette Socket dans le conteneur, la client du conteneur *docker* sera en mesure d'interagir avec un démon, et donc de construire notre image.
Cette technique est connue sous le nom de DinD (Docker in Docker).

Testons cette approche, en créant un pod, qui monte la Socket en tant que volume :
```sh
cat << EOF > docker-ind.yaml
---
apiVersion: v1
kind: Pod
metadata:
  name: docker-ind
spec:
  containers:
  - name: docker
    image: docker
    args: ["sleep", "10000"]
    volumeMounts:
    - mountPath: /var/run/docker.sock
      name: docker-socket
  restartPolicy: Never
  volumes:
  - name: docker-socket
    hostPath:
      path: /var/run/docker.sock
EOF
```{{execute HOST2}}

et exécutons le sur K8S :

`kubectl apply -f docker-ind.yaml`{{execute HOST2}}

Attendons que le pod soit dans un état stable :
`kubectl wait --timeout=90s --for condition=containersready pod docker-ind`{{execute HOST1}}

Et exécutons un shell dans le conteneur *docker* :
`kubectl exec -ti docker-ind -- sh`{{execute HOST2}}

Construisons notre image à l'intérieur du conteneur :
```sh
cd /tmp
cat << EOF > Dockerfile
FROM alpine
CMD ["/bin/echo", "\u001b[31mIt is alive DinD !!!\u001b[m\r\n"]
EOF
docker build -t my-super-image .
docker run -ti my-super-image
```{{execute HOST2}}

Cela fonctionne ! Problème réglé !

Pas vraiment.
Tout d'abord parce que Docker ne fera plus partie des futures distributions K8S.
Ensuite, parce que la technique DinD pose une faille de sécurité majeure : accéder au démon Docker de l'hôte depuis un conteneur peut conduire à des effets de bords a minima génants.

vous voulez le constater par vous mêmes ? Alors appliquons la méthode Saint Thomas (qui ne croit que ce qu'il voit).

Sur notre cluster K8S, un pod proposant des citations de la séries *Friends* s'exécute.
Affichons ses logs dans un nouvel onglet :
`sleep 1; kubectl logs -f friends`{{execute HOST1}}

Retournons sur le premier onglet, à l'intérieur de notre conteneur *docker*. Nous pouvons requêter le démon du noeud K8S, via la Socket montée en volume. Cherchons notre conteneur *friends* :
`docker ps --filter="ancestor=plopezfr/friends-quotes:1.0"`{{execute HOST2}}
Le conteneur remonte bien dans la liste des conteneurs en cours d'exécution,  nous avons donc accès à tous les conteneurs du noeud.

Nous pouvons même le *terminer* :
`docker kill $(docker ps -a -q --filter="ancestor=plopezfr/friends-quotes:1.0" --format="{{.ID}}")`{{execute HOST2}}

Sur le second onglet, les logs se sont interrompues sans explication. Et le statut du pod est édifiant :
`kubectl get pods`{{execute HOST1}}

Du coup, la technique DinD est plutôt à proscrire.

Fermons le second terminal, sortons du conteneur *docker* (en tapant <kbd>exit</kbd>) et faisons un brin de ménage :
```sh
kubectl delete -f docker-ind.yaml && clear
```{{execute HOST2}}
