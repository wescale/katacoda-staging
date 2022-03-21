
**Podman-Compose**


`pip3 install podman-compose`{{execute}}

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

`podman-compose --help`{{execute}}

`podman-compose up --help`{{execute}}

`podman-compose up -d`{{execute}}

`podman-compose ps`{{execute}}

`podman-compose images`{{execute}}