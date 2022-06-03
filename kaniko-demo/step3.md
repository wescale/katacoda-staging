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
    image: rg.fr-par.scw.cloud/katacoda/docker:latest
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
```{{exec}}

et exécutons le sur K8S :

`kubectl apply -f docker-ind.yaml`{{exec}}

Attendons que le pod soit dans un état stable :
`kubectl wait --timeout=90s --for condition=containersready pod docker-ind`{{exec}}

Et exécutons un shell dans le conteneur *docker*, pour lancer notre build :
`kubectl exec -ti docker-ind -- sh`{{exec}}

Construisons notre image à l'intérieur du conteneur :
```sh
cd /tmp
cat << EOF > Dockerfile
FROM rg.fr-par.scw.cloud/katacoda/alpine:latest
CMD ["/bin/echo", "\u001b[31mIt is alive DinD !!!\u001b[m\r\n"]
EOF
docker build -t my-super-image .
docker run -ti my-super-image
```{{exec}}

Cela fonctionne ! Problème réglé !

Pas vraiment.
Tout d'abord parce que Docker ne fera plus partie des futures distributions K8S.
Ensuite, parce que la technique DinD pose une faille de sécurité majeure : accéder au démon Docker de l'hôte depuis un conteneur peut conduire à des effets de bords a minima gênants.

Vous voulez le constater par vous-même ? Alors appliquons la méthode Saint Thomas (qui ne croit que ce qu'il voit).

Sur notre cluster K8S, un pod proposant des citations de la séries *Friends* s'exécute.
Affichons ses logs dans un nouvel onglet :
`sleep 1; kubectl logs -f friends`{{exec}}

Retournons sur le premier onglet, à l'intérieur de notre conteneur *docker*. Nous pouvons requêter le démon du noeud K8S, via la Socket montée en volume. Cherchons notre conteneur *friends* :
`docker ps --filter="ancestor=rg.fr-par.scw.cloud/katacoda/friends-quotes:latest"`{{exec}}
Le conteneur remonte bien dans la liste des conteneurs en cours d'exécution, nous avons donc accès à tous les conteneurs du noeud.

Nous pouvons même le *terminer* :
`docker kill $(docker ps -a -q --filter="ancestor=rg.fr-par.scw.cloud/katacoda/friends-quotes:latest" --format="{{.ID}}")`{{exec}}

Sur le second onglet, les logs se sont interrompus sans explication. Et le statut du pod est édifiant :
`kubectl get pods`{{exec}}

Du coup, la technique DinD est plutôt à proscrire.

⚠️ Sortons du conteneur *docker* (`exit`{{exec}})⚠️

🚩 N'oubliez pas cette étape, sinon le reste du scénario sera dysfonctionnel.

 et faisons un brin de ménage :
```sh
kubectl delete -f docker-ind.yaml &
sleep 2 && clear
```{{exec}}
