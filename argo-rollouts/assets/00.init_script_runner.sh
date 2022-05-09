#!/bin/bash

NAMESPACE=argo-rollouts
ARGO_VERSION=v1.2.0

show_progress()
{
  clear
  echo "Il reste 5 étapes à paramétrer avant de démarrer ce tuto"
  echo -n " "

  echo -n "[Etape 1/5] K8S est en train de chauffer"
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
  clear && echo -n "[Etape 2/5] Les noeuds rejoignent le cluster K8S"
  echo -n " "

  kubectl wait --for=condition=Ready nodes --all --timeout=120s
  ssh -q $(kubectl get node --selector='!node-role.kubernetes.io/master' -o jsonpath={.items[*].status.addresses[?\(@.type==\"InternalIP\"\)].address}) 'mkdir -p /root/.kube'
  scp -q /root/.kube/config $(kubectl get node --selector='!node-role.kubernetes.io/master' -o jsonpath={.items[*].status.addresses[?\(@.type==\"InternalIP\"\)].address}):/root/.kube/config
  

  #  ===================== Create the NGINX Ingress ==========================
  clear && echo -n "[Etape 3/5] Déploiement des CRDs de l'ingress Nginx"
  echo -n " "

  kubectl create namespace ingress-nginx

  helm upgrade --install ingress-nginx ingress-nginx \
    --repo https://kubernetes.github.io/ingress-nginx \
    --namespace ingress-nginx --version='<4'

  # ===================== Create the K8S namespace ==========================
  clear && echo -n "[Etape 4/5] Création du namespace dédié au tuto\n\n"
  kubectl create namespace "${NAMESPACE}"

  # ===================== Installation of the Argo-Rollouts CRD ==========================

  clear && echo -n "[Etape 5/5] Installation de l'interface Argo-rollouts \n\n"
 
  # Install the Dashboard - should be installed in the current namespace
  kubectl apply -f https://github.com/argoproj/argo-rollouts/releases/download/${ARGO_VERSION}/dashboard-install.yaml

  # Wait for ingress to be available
  kubectl wait --namespace ingress-nginx \
    --for=condition=ready pod \
    --selector=app.kubernetes.io/component=controller \
    --timeout=120s

  # Install the ingress
  kubectl apply -f "$(dirname $0)/00.argo-rollouts-dashboard-ingress.yml"
  
  clear
  echo -n "Paramétrage effectué, paré au lancement"
  echo -n ""
}

show_progress
