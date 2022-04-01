
**Simuler les objets k8s avec Podman, oui c'est possible !**

# Créer un pod

`podman pod create -p 8080:80 --name pod01`{{execute}}

# Lister l'ensemble des Pods 

`podman pod ls`{{execute}}

# Lancer un conteneur dans un pod 

`podman container run -d --name container01 --pod pod01 docker.io/library/httpd`{{execute}}

# Lister l'ensemble des conteneurs 

`podman container ls`{{execute}}

# Rajoutons deux autres conteneurs dans le pod

`podman container run -d --name container02 --pod pod01 docker.io/library/mariadb`{{execute}}

#  et un troisième ...

`podman container run -d --name container03 --pod pod01 docker.io/library/redis`{{execute}}

# lister l'ensemble des pods

`podman pod ls`{{execute}}

# lister l'ensemble des conteneurs

`podman container ls`{{execute}}

# Générons les manifests: Pod et Service

`podman generate kube -f pod.yml pod01`{{execute}}

`less pod.yml`{{execute}}

` podman generate kube --service pod01 > service.yml `{{execute}}

`less service.yml`{{execute}}

# stop et arreter tout

`podman pod stop --all`{{execute}}

`podman pod rm -f --all`{{execute}}

# Recréer l'ensemble en une seule commande: 

`podman play kube pod.yml`{{execute}}