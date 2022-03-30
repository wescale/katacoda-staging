
**How to use Podman to run containers in separate user namespaces.**


`sudo bash -c "echo Test > /tmp/test"`{{execute}}

`sudo chmod 600 /tmp/test`{{execute}}

`sudo ls -l /tmp/test`{{execute}}

`sudo podman run -ti -v /tmp/test:/tmp/test:Z --uidmap 0:100000:5000 fedora sh`{{execute}}

`id`{{execute}}

`ls -l /tmp/test`{{execute}}

`cat /tmp/test`{{execute}}

`exit`{{execute}}


**Tutorial to run containers in rootless.**

`cd $HOME`{{execute}}
`mkdir rootless-tuto`{{execute}}
`id -u $(whoami)`{{execute}}
`podman run --user 200 -it -v $(pwd)/rootless-tuto:/mnt/rootless-tuto:Z busybox`{{execute}}
## The directory is owned by root – not user “200”, or my user ID.
`id -u $(whoami)`{{execute}}
`ls -al /mnt`{{execute}}
`touch /mnt/rootless-tuto/test`{{execute}}

## This means that if you’re running your container process as a non-root user, it won’t be able to write to that directory.

## So how do we change the owner of the directory in the container, so the user can write to it?

## And how can we troubleshoot and run commands in that same user namespace, when things go wrong – without having to start a container?

`podman ps -a`{{execute}}
`sudo adduser wescale`{{execute}}
`su - wescale`{{execute}}
`podman ps -a`{{execute}}
`mkdir /repo`{{execute}}

`podman run -it --rm --name nexus2 -v /repo:/sonatype-work:Z sonatype/nexus /bin/sh`{{execute}}

