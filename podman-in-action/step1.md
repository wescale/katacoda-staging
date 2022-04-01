
**Installation Podman dans Ubuntu**


Nous commençons par sourcer l'os-release:  `. /etc/os-release`{{execute}}

Ensuite nous ajouter le repo kubic qui contiendra podman, ainsi que la clé GPG: `echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list`{{execute}}

`curl -L "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/Release.key" | sudo apt-key add -`{{execute}}

Nous mettons à jour le system: `sudo apt-get -y update`{{execute}}

Et enfin, nous lançons l'installation de la dernière version de Podman: `sudo apt-get -y install podman`{{execute}}

Vérifions maintenant que podman c'est bien installé:  

`podman --version`{{execute}}
