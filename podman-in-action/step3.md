
**Le flag --replace**


`podman run --name test ubi8 echo hello`{{execute}}

`podman run --name test ubi8 echo goodbye`{{execute}}

`podman run --replace --name test ubi8 echo goodbye`{{execute}}


**Le flag --all**

Arrêter l'ensemble des conteneurs: `podman stop --all`{{execute}}

Supprimer l'ensemble des conteneurs: `podman rm --all`{{execute}}

Supprimer l'ensemble des images: `podman rmi --all`{{execute}}

Supprimer l'ensemble des conteneurs, même s'ils sont déja démarrées:

`podman run -d nginx`{{execute}}

`podman ps`{{execute}}

`podman rm --all --force`{{execute}}

`podman ps`{{execute}}


**Le flag --ignore**

`podman run --name test1 ubi8`{{execute}}

`podman run --name test3 ubi8`{{execute}}

`podman rm test1 test2 test3`{{execute}}

`podman ps -a`{{execute}}

`podman rm --ignore test1 test2 test3`{{execute}}


