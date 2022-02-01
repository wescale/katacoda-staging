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

  wget -q https://raw.githubusercontent.com/argoproj/argo-workflows/master/manifests/base/argo-server/argo-server-sa.yaml

  kubectl apply -f argo-server-sa.yaml

  kubectl apply -f deployment.yaml

  wget -q https://raw.githubusercontent.com/argoproj/argo-workflows/master/manifests/base/argo-server/argo-server-service.yaml

  kubectl apply -f argo-server-service.yaml

  kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

  kubectl apply -f ingress.yaml
}

show_progress
