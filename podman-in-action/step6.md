
**Simuler les objets k8s avec Podman, oui c'est possible !**

Nous commencer par créer un pod

`podman pod create -p 8080:80 --name pod01`{{execute}}

Vérifions si le pod est bien créer: 

`podman pod ls`{{execute}}

Nous lançons un conteneur au sein du pod: 

`podman container run -d --name container01 --pod pod01 docker.io/library/httpd`{{execute}}

Et vérifions si le conteneur est bien présent: 

`podman container ls`{{execute}}

Nous rajoutons maintenant deux autres conteneurs dans le pod

`podman container run -d --name container02 --pod pod01 docker.io/library/mariadb`{{execute}}

`podman container run -d --name container03 --pod pod01 docker.io/library/redis`{{execute}}

Vérifions si les conteneurs sont bien là: 

`podman container ls`{{execute}}

Tout fonctionne comme on veut, super ! Aller, on génére les manifests Kube, et on commence par le pod:

`podman generate kube -f pod.yml pod01`{{execute}}

Vérifions si le manifest du pod: 

`less pod.yml`{{execute}}

Générons maintenant le manifest du service

` podman generate kube --service pod01 > service.yml `{{execute}}

`less service.yml`{{execute}}

On supprime tout ce qu'on a crée: 

`podman pod stop --all`{{execute}}

`podman pod rm -f --all`{{execute}}

Recréeons maintenant l'ensemble en une seule commande: 

`podman play kube pod.yml`{{execute}}