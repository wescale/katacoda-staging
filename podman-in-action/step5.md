
**Comment utilser Podman afin de lancer les conteneurs dans des namespaces différents:**

`sudo bash -c "echo Test > /tmp/test"`{{execute}}

`sudo chmod 600 /tmp/test`{{execute}}

`sudo ls -l /tmp/test`{{execute}}

`sudo podman run -ti -v /tmp/test:/tmp/test:Z --uidmap 0:100000:5000 fedora sh`{{execute}}

`id`{{execute}}

`ls -l /tmp/test`{{execute}}

`cat /tmp/test`{{execute}}

`exit`{{execute}}


**Testons concrétement ce que c'est un rootless:**

Nous lancons un conteneur Nexus, et souhaitons que les artefacts seront copier dans un dossier au niveau du Host.
Nous démarrons avec un lancement du conteneur nexus autant que root.

`mkdir $HOME/nexus-repo-root`{{execute}}

`id -u $(whoami)`{{execute}}

`podman run -it --rm --name nexus2 -v $HOME/nexus-repo-root:/sonatype-work:Z sonatype/nexus /bin/sh`{{execute}}

## Le propriètaire du dossier est root, et non l'ID 200 ou mon ID utilisateur

`id -u $(whoami)`{{execute}}

`ls -al / | grep sonatype-work`{{execute}}

## Testons une création d'un fichier dans ce dossier. 

`touch /sonatype-work/test`{{execute}}

`exit`{{execute}}

## Utilisons l'option unshare pour lancer une commande qui utilisera le même namespace utilisateur que le conteneur, dans notre cas l'UID 200.

`podman unshare chown 200:200 -R $HOME/nexus-repo-root`{{execute}}

`podman ps -a`{{execute}}

## Rajoutons un nouveau utilisateur, pour lancer podman en rootless, et reexutons le même scénario. Maintenant, tout fonctionne comme prévu
`sudo adduser wescale`{{execute}}

`su - wescale`{{execute}}

`podman ps -a`{{execute}}

`mkdir $HOME/nexus-repo-wescale`{{execute}}

`podman run -it --rm --name nexus2 -v $HOME/nexus-repo-wescale:/sonatype-work:Z sonatype/nexus /bin/sh`{{execute}}

`ls -al / | grep sonatype-work`{{execute}}

`touch /sonatype-work/test`{{execute}}

`exit`{{execute}}

`podman unshare chown 200:200 -R $HOME/nexus-repo-wescale`{{execute}}

`podman run -it --rm --name nexus2 -v  $HOME/nexus-repo-wescale:/sonatype-work:Z sonatype/nexus /bin/sh`{{execute}}

`ls -al / | grep sonatype-work`{{execute}}

`touch /sonatype-work/test`{{execute}}

`exit`{{execute}}

`ls -al nexus-repo-wescale/`{{execute}}

