# A la découverte de Kaniko, localement

Pour nous sortir de l'impasse, utilisons Kaniko.
Kaniko peut constuire des images Docker, à l'intérieur d'un conteneur, sans reposer sur un démon Docker. Chaque commande du Dockerfile s'exécute au sein de l'espace utilisateur, et constuit, couche après couche, l'image.
Cela permet donc de constuire des images Docker en toute sécurité, même au sein d'un cluster K8S.

Essayons cet outil localement.

`cat << EOF > Dockerfile
FROM alpine
CMD ["/bin/echo", "\u001b[31mIt is alive and built by Kaniko!!!\u001b[m\r\n"]
EOF
`{{execute HOST2}}

`cat Dockerfile`{{execute HOST2}}

Construisons notre image avec Kaniko, qui dispose d'un conteneur officiel, héberger sur la registry Google :
```
docker run \
  -v $(pwd):/workspace gcr.io/kaniko-project/executor:latest \
  --context dir:///workspace \
  --destination=my-new-super-image:latest \
  --no-push \
  --tarPath=/workspace/my-new-super-image.tar
```{{execute HOST2}}

Nous avons utilisé des options particulières pour exporter l'image localement sous forme de tar, et ne pas la pousser dans une registry (à des fins d'exemple).
Nous pouvons maintenant charger ce tar dans notre démon Docker local et l'exécuter
```
docker load --input my-new-super-image.tar
docker run  my-new-super-image
```{{execute HOST2}}

Retour au point de départ, nous sommes capables de construire des images localement, mais cette fois avec Kaniko.
