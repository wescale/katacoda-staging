#!/bin/bash

show_progress()
{
  echo -n "K8S is still warming up"
  local -r pid="${1}"
  local -r delay='0.75'
  local spinstr='\|/-'
  local temp
  while true; do
    kubectl version &> /dev/null
    if [[ "$?" -ne 0 ]]; then
      temp="${spinstr#?}"
      printf " [%c]  " "${spinstr}"
      spinstr=${temp}${spinstr%"${temp}"}
      sleep "${delay}"
      printf "\b\b\b\b\b\b"
    else
      break
    fi
  done
  printf "    \b\b\b\b"
  echo ""
  echo "K8S Ready, waiting for nodes to join Cluster"

  kubectl wait --for=condition=Ready nodes --all --timeout=120s
  ssh -q $(kubectl get node --selector='!node-role.kubernetes.io/master' -o jsonpath={.items[*].status.addresses[?\(@.type==\"InternalIP\"\)].address}) 'mkdir -p /root/.kube'
  scp -q /root/.kube/config $(kubectl get node --selector='!node-role.kubernetes.io/master' -o jsonpath={.items[*].status.addresses[?\(@.type==\"InternalIP\"\)].address}):/root/.kube/config


  echo "Nodes Ready, waiting ingress deployment"

  kubectl create namespace ingress-nginx

  helm upgrade --install ingress-nginx ingress-nginx \
    --repo https://kubernetes.github.io/ingress-nginx \
    --namespace ingress-nginx --version='<4'

  wget https://raw.githubusercontent.com/argoproj/argo-workflows/master/manifests/base/argo-server/argo-server-sa.yaml

  kubectl apply -f argo-server-sa.yaml

  cat << EOF > deployment.yaml
  ---
  apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: argo-server
  spec:
    selector:
      matchLabels:
        app: argo-server
    template:
      metadata:
        labels:
          app: argo-server
      spec:
        serviceAccountName: argo-server
        containers:
          - name: argo-server
            image: quay.io/argoproj/argocli:latest
            securityContext:
              capabilities:
                drop:
                  - ALL
            args: [ server ]
            env:
            #- name: BASE_HREF
            #  value: /argo/
            ports:
              - name: web
                containerPort: 2746
            readinessProbe:
              httpGet:
                port: 2746
                scheme: HTTPS
                path: /
              initialDelaySeconds: 10
              periodSeconds: 20
            volumeMounts:
              - mountPath: /tmp
                name: tmp
        volumes:
          - name: tmp
            emptyDir: { }
        securityContext:
          runAsNonRoot: true
        nodeSelector:
          kubernetes.io/os: linux
  EOF

  kubectl apply -f deployment.yaml

  wget https://raw.githubusercontent.com/argoproj/argo-workflows/master/manifests/base/argo-server/argo-server-service.yaml

  kubectl apply -f argo-server-service.yaml

  cat << EOF > ingress.yaml
  ---
  apiVersion: networking.k8s.io/v1beta1
  kind: Ingress
  metadata:
    name: argo-server
    annotations:
      ingress.kubernetes.io/rewrite-target: /$2
      nginx.ingress.kubernetes.io/backend-protocol: https # ingress-nginx
  spec:
    rules:
      - http:
          paths:
            - backend:
                serviceName: argo-server
                servicePort: 2746
              #path: /argo(/|$)(.*)
              path: /
  EOF

  kubectl apply -f ingress.yaml
}

show_progress
