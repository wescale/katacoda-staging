#/bin/bash
cat << EOF > friends.yaml
---
apiVersion: v1
kind: Pod
metadata:
  name: friends
spec:
  containers:
  - name: friends
    image: plopezfr/friends-quotes:1.0
  restartPolicy: Never
EOF

sleep 2

kubectl apply -f friends.yaml

sleep 2

# Creation d'une registry privée
#!/bin/bash
mkdir -p ./registry/certs ./registry/auth

openssl req -x509 -newkey rsa:4096 -days 365 -nodes -sha256 -keyout registry/certs/tls.key -out registry/certs/tls.crt -subj "/CN=docker-registry"
SECRETMANIFEST="secrets-auth.yaml"

cat << EOF > "$SECRETMANIFEST"
---
apiVersion: v1
kind: Secret
metadata:
  name: certs-secret-docker-registry
type: kubernetes.io/tls
data:
  tls.crt: $(cat registry/certs/tls.crt | base64 --wrap=0)
  tls.key: $(cat registry/certs/tls.key | base64 --wrap=0)
EOF

AUTHFILE="registry/auth/htpasswd"
docker run --rm --entrypoint htpasswd registry:2.6.2 -Bbn "login" "password" > "$AUTHFILE"

cat << EOF >> "$SECRETMANIFEST"
---
apiVersion: v1
kind: Secret
metadata:
  name: auth-secret-docker-registry
type: Opaque
data:
  username: $(echo "login" | base64 --wrap=0)
  password: $(echo "password" | base64 --wrap=0)
EOF

cat << EOF >> "$SECRETMANIFEST"
---
apiVersion: v1
kind: Secret
metadata:
  name: auth-secret-docker-registry
type: Opaque
data:
  htpasswd: $(cat registry/auth/htpasswd | base64 --wrap=0)
EOF

kubectl apply -f secrets-auth.yaml

kubectl apply -f registry.yaml

clusterIP=""
while [ -z $clusterIP ]; do
  clusterIP=$(kubectl get svc docker-registry -o jsonpath='{.spec.clusterIP}')
  [ -z "$clusterIP" ] && sleep 10
done

echo $(kubectl get svc -A | grep -E "docker-registry.*5000" | awk '{print $4"  docker-registry"}') >> /etc/hosts

mkdir -p /etc/docker/certs.d/docker-registry:5000
cp registry/certs/tls.crt /etc/docker/certs.d/docker-registry:5000/.