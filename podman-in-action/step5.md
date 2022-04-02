**C'est quoi l'user namespace**
Voici ce qu'est un user namespace dans la documentation officielle:        
       
"User namespaces **isolate** security-related identifiers and attributes, in particular, **user IDs** and **group IDs**, the **root directory**, and **capabilities**.A process's user and group IDs can be different inside and outside a user namespace. In particular, a process can have a normal unprivileged user ID outside a user namespace while at the same time having a user ID of 0 inside the namespace; in other words, the process has full privileges for operations inside the user namespace, but is unprivileged for operations outside the namespace."

Le "user namespace" permet d'isoler les UIDs et GIDs entre vos conteneurs et votre host. Il est possible de voir ce mapping en observant le fichier /proc/self/uid_map dans votre conteneur.

Il est ainsi possible de configurer le user namespace pour donner la possibilité au conteneur à voir uniquement un sous ensemble des UIDs/GIDs de la machine Host. Voici un exemple permettant d'illustrer ceci: 

**Comment utilser Podman afin de lancer un conteneurs isolant les UIDs/GIds gràce au "users namespaces":**

`sudo bash -c "echo Test > /tmp/test"`{{execute}}

`sudo chmod 600 /tmp/test`{{execute}}

`sudo ls -l /tmp/test`{{execute}}

Lançons le conteneur fedora avec un mapping de namespace utilisateur 0:100000:5000. Ici On mappe 5000 utilisateur, et en démarrant avec l'UID 100000 à l'exterieur du POD, qui correspondera à l'utilisateur 0 (root) dans le conteneur. 
(UID Out) 10000 -> 0  (UID IN)
(UID Out) 10001 -> 1  (UID IN)
...
(UID Out) 14999 -> 4999  (UID IN)

`sudo podman run -ti -v /tmp/test:/tmp/test:Z --uidmap 0:100000:5000 fedora sh`{{execute}}

`cat /proc/self/uid_map`{{execute}}

`id`{{execute}}

`ls -l /tmp/test`{{execute}}

`cat /tmp/test`{{execute}}

`exit`{{execute}}


**Testons concrétement ce que c'est un rootless:**

Pour obtenir un conteneur Rootless, nous devrons lancer Podman par un utilisateur non root.

Quand vous lancez un rootless podman, il utilise **user namespace** pour mapper entre les utilisateurs ID dans le conteneur et les utilisateurs ID dans le host.

L'ensemble des conteneurs rootless lancés par un utilisateur (non root évidement), sont lancés avec le même "user namespace". (comme si on a passé --uidmap 0:<uid utilisateur:1>). 

Donc, si l'un de ces conteneurs démarre avec un volume, il apparait à l'interieur de l'user namaspace appartenant à root. (--uidmap 0:<uid utilisateur:1> c'est à dire appartenant à root à l'interieur du conteneur, et appartenantn à l'utilisateur au niveau de la machine host).

Ainsi, si vous lancez votre conteneur avec un utilisateur non root, il n'est pas possible d'écrire dans un volume.

Comment peut-on faire pour changer le proprièataire de ce dossier dans le conteneur, pour que le conteneur à écrire dans ce dossier ?
Et comment, peut-on faire pour lancer des commandes dans le conteneur avec le même "user namespace", quand il y a des erreurs et pour ne pas avoir besoin de démarrer le conteneur ?

La réponse sera donné dans l'exemple suivant: 

Nous lancons un conteneur Nexus, et souhaitons que les artefacts seront copiés dans un dossier au niveau du Host.
Nous démarrons le conteneur nexus autant que root et un volume qui ne peut pas être partagé à d'autres conteneurs (:Z)

`mkdir $HOME/nexus-repo-root`{{execute}}

`id -u $(whoami)`{{execute}}

`podman run -it --rm --name nexus2 -v $HOME/nexus-repo-root:/sonatype-work:Z sonatype/nexus /bin/sh`{{execute}}

## Le propriètaire du dossier est root, et non l'ID 200 ou mon ID utilisateur

`id -u $(whoami)`{{execute}}

`ls -al / | grep sonatype-work`{{execute}}

## Testons une création d'un fichier dans ce dossier. 

`touch /sonatype-work/test`{{execute}}

`exit`{{execute}}

## Utilisons l'option unshare

L'option unshare permet de lancer une commande dans le même user namespace que celui du conteneur (root dans notre cas:  0:uid utilisateur). 
Utilisons donc podman unshare pour que l'utilisateur 200 dans le conteneur nexus ait les droits à écrire dans ce dossier: 

`podman unshare chown 200:200 -R $HOME/nexus-repo-root`{{execute}}

Ceci ne fonctionne pas, effectictement on ne peut pas lancer unshare uniquement que rootless: 

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

