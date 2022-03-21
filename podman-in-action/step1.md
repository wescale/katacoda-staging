

D'abord, nous rajoutons le repo Kubic projoet à notre ubuntu 20.4 :

`. /etc/os-release`{{execute}}

`echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list`{{execute}}

`curl -L "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/Release.key" | sudo apt-key add -`{{execute}}

Ensuite, nous installons Podman dans le system:
`sudo apt-get -y update`{{execute}}

`sudo apt-get -y install podman`{{execute}}

Enfin, nous vérifions que l'installation est réalisée et nous vérifions la version: 

`podman --version`{{execute}}
