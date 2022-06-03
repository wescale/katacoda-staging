Constuire une image localement est généralement la première chose que l'on apprend en utilisant Docker.
La ligne de commande (CLI) interagit avec le démon Docker local, et permet d'enchainer les instructions contenues dans le Dockerfile pour construire une image.

Utilisons un Dockerfile simple (voire simpliste):

```
cat << EOF > Dockerfile
FROM rg.fr-par.scw.cloud/katacoda/alpine:latest
CMD ["/bin/echo", "\u001b[31mIt is alive !!!\u001b[m\r\n"]
EOF
```{{exec}}


Et construisons l'image qu'il définit :
`docker build -t my-super-image .`{{exec}}

L'image existe maintenant localement, et nous pouvons l'exécuter :
```sh
clear
docker run my-super-image
```{{exec}}

Yeah !
