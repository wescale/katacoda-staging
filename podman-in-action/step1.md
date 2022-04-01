
**Installation Podman dans Ubuntu**


Sourcer l'os-release:  `. /etc/os-release`{{execute}}

Rajouter le repo kubic: `echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list`{{execute}}

Ajouter la clé GPG:  `curl -L "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/Release.key" | sudo apt-key add -`{{execute}}

Mise à jour du system: `sudo apt-get -y update`{{execute}}

Installation de Podman: `sudo apt-get -y install podman`{{execute}}

Enfin, nous vérifions que l'installation est réalisée et nous vérifions la version: 

`podman --version`{{execute}}
