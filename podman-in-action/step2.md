
**Démarrer un conteneur avec Podman**


`podman pull docker.io/nginx`{{execute}}

`podman  run -dt --name podman-nginx -p 8080:80 docker.io/nginx`{{execute}}

`podman port -l`{{execute}}

`podman inspect -l`{{execute}}

`podman images`{{execute}}

`podman ps`{{execute}}

`podman ps -a`{{execute}}

`curl 127.0.0.1:8080`{{execute}}

`podman stop podman-nginx `{{execute}}

`podman rm podman-nginx `{{execute}}


**Construction d'une image avec Podman**


`git clone https://github.com/scriptcamp/podman.git`{{execute}}

`cd podman/nginx-image`{{execute}}

`podman build -t scriptcamp/nginx .`{{execute}}
