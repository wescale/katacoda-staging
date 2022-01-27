Constuire une image localement est généralement la première chose que l'on apprend en utilisant Docker.
La ligne de commande (CLI) interagit avec le démon Docker local, et permet d'enchaine les instructions contenues dans le Dockerfile pour constuire une image.

Utilisons un Dockerfile simple (voire simpliste):

`cat << EOF > Dockerfile
FROM alpine
CMD ["/bin/echo", "\u001b[31mIt is alive !!!\u001b[m\r\n"]
EOF
`{{execute HOST2}}


Et construisons l'image qu'il définit :
`docker build -t my-super-image .`{{execute HOST2}}

L'image existe maintenant localement, et nous pouvons l'exécuter :
```sh
clear
docker run my-super-image
```{{execute HOST2}}

Yeah !
