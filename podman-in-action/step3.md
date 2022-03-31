
**The --replace flag**


`podman run --name test ubi8 echo hello`{{execute}}

`podman run --name test ubi8 echo goodbye`{{execute}}

`podman run --replace --name test ubi8 echo goodbye`{{execute}}


**The --all flag**

- **Stop all Podman containers**
`podman stop --all`{{execute}}

- **Remove all Podman containers**
`podman rm --all`{{execute}}

- **Remove all Podman images** 
`podman rmi --all`{{execute}}

- **You can remove all containers even if they are running with the Podman command below:**
  
`podman run -d nginx`{{execute}}

`podman ps`{{execute}}

`podman rm --all --force`{{execute}}

`podman ps`{{execute}}



**The --ignore flag**

`podman run --name test1 ubi8`{{execute}}

`podman run --name test3 ubi8`{{execute}}

`podman rm test1 test2 test3`{{execute}}

`podman ps -a`{{execute}}

`podman rm --ignore test1 test2 test3`{{execute}}


