# Not working :'(

Imagine now that you need to build your image in a distant CI (incredible...)

The common way is to have an independent CI runner, hosting the Docker Daemon, and doing the exact same thing you did on your local computer.

But why is there a need for another machine / service, if we plan to run our container on K8S. Couldn't we use the existing K8S infrastructure to build our container upon ?

There is an official Docker image, so let's use it.

First we create a pod running docker, and we add a sleep command to have time to enter it :
```sh
cat << EOF > docker.yaml
---
apiVersion: v1
kind: Pod
metadata:
  name: docker
spec:
  containers:
  - name: docker
    image: docker
    args: ["sleep", "10000"]
  restartPolicy: Never
EOF
```{{execute}}

and run it on K8S :

`kubectl apply -f docker.yaml`{{execute}}

We wait for the pod to be up and running
`kubectl wait --for condition=containersready pod docker`{{execute}}

Then, we exevute a shell into the image
`kubectl exec -ti docker -- sh`{{execute}}

and we try to build our image inside the containers
```sh
cd /tmp
cat << EOF > Dockerfile
FROM alpine
CMD ["/bin/echo", "It is alive !!!"]
EOF
docker build -t my-super-image .
```{{execute}}

You should see an error. Why ? Because Docker Daemon is not running inside this container. Docker container only contains docker CLI.

Exit the container (type `exit`)
```sh
kubectl delete -f docker.yaml
```{{execute}}
