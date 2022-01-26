# The right way. A local first step.

That is where Kaniko comes to the rescue.
Kaniko doesn't depend on a Docker daemon and executes each command within a Dockerfile completely in userspace. This enables building container images in environments that can't easily or securely run a Docker daemon, such as a standard Kubernetes cluster.

Let's give it a try.

`cat << EOF > Dockerfile
FROM alpine
CMD ["/bin/echo", "It is alive and built by Kaniko !!!"]
EOF
`{{execute}}

`cat Dockerfile`{{execute}}

Now we will try to build our image with Kaniko, locally :
```
docker run \
  -v $(pwd):/workspace gcr.io/kaniko-project/executor:latest \
  --context dir:///workspace \
  --destination=my-new-super-image:latest \
  --no-push \
  --tarPath=/workspace/my-new-super-image.tar
```{{execute}}

Load the image and run it
```
docker load --input my-new-super-image.tar
docker run  my-new-super-image
```{{execute}}
