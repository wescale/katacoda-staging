
**Construction d'une image avec Podman**


`git clone https://github.com/scriptcamp/podman.git`{{execute}}

`cd podman/nginx-image`{{execute}}

`podman build -t scriptcamp/nginx .`{{execute}}

`podman push scriptcamp/nginx`{{execute}}

`podman images`{{execute}}

`podman ps`{{execute}}

`podman ps -a`{{execute}}

`podman stop podman-nginx `{{execute}}

`podman rm podman-nginx `{{execute}}

