
**A container in a pod**

# Create a pod

`podman pod create -p 8080:80 --name pod01`{{execute}}

# List Pods 

`podman pod ls`{{execute}}

# Start a container in the pod

`podman container run -d --name container01 --pod pod01 docker.io/library/httpd`{{execute}}

# List containers

`podman container ls`{{execute}}

# Let's add two more containers to the pod.

`podman container run -d --name container02 --pod pod01 docker.io/library/mariadb`{{execute}}

# Start a third container in the pod

`podman container run -d --name container03 --pod pod01 docker.io/library/redis`{{execute}}

# List pods

`podman pod ls`{{execute}}

# List containers

`podman container ls`{{execute}}

# Generate manifest 

`podman generate kube -f pod.yml pod01`{{execute}}

`less pod.yml`{{execute}}

`podman generate kube -f pod.yml pod01`{{execute}}

` podman generate kube --service pod01 > service.yml `{{execute}}

`less service.yml`{{execute}}

`podman pod stop --all`{{execute}}

`podman pod rm -f --all`{{execute}}

`podman play kube pod.yml`{{execute}}