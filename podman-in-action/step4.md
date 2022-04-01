
**Docker-Compose AS Podman-Compose**

podman-compose est apparu à partir de la version 3.0. Il fonctionne de la même manière que docker-compose.
Voici un exemple du fonctionnement de podman-compose:

Installation podman-compose: `pip3 install podman-compose`{{execute}}

podman-compose continue à utiliser un docker-compose.yaml:

```sh
cat << EOF > docker-compose.yaml
---
version: "2"
services:

    redis:
      image: redis:alpine
      ports:
        - "6379"
      environment:
        - SECRET_KEY=aabbcc
        - ENV_IS_SET

    frontend:
      image: busybox
      #entrypoint: []
      command: ["/bin/busybox", "httpd", "-f", "-p", "8080"]
      working_dir: /
      environment:
        SECRET_KEY2: aabbcc
        ENV_IS_SET2:
      ports:
        - "8080"
      links:
        - redis:myredis
      labels:
        my.label: my_value
EOF
```{{execute}}

Up du podman-compose: `podman-compose up -d`{{execute}}

Vérfier que tout est bon: `podman-compose ps`{{execute}}