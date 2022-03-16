

First, let's add Kubic project repository to our Ubuntu 20.04

`. /etc/os-release`{{execute}}

`echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list`{{execute}}

`curl -L "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/xUbuntu_${VERSION_ID}/Release.key" | sudo apt-key add -`{{execute}}

Secon install Podman in the system
`sudo apt-get -y update`{{execute}}

`sudo apt-get -y install podman`{{execute}}

To verify the installation, let's display the version of podman deployed

`podman --version`{{execute}}
