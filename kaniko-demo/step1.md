This is the baseline when you work with containers.
You buils them locally, using the Docker Daemon. And everything if fine as long as you do it on your own computer.

Everything starts with a very simple Dockerfile :

`cat << EOF > Dockerfile
FROM alpine
CMD ["/bin/echo", "It is alive !!!"]
EOF
`{{execute}}

`cat Dockerfile`{{execute}}

First, we build it :
`docker build -t my-super-image .`{{execute}}

Then, we run it :
`docker run my-super-image`{{execute}}

Yeah !
