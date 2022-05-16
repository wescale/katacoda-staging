#!/bin/bash

NAMESPACE=argo-rollouts
ARGO_VERSION=v1.2.0

show_progress()
{
  clear
  echo "Il reste 5 étapes à paramétrer avant de démarrer ce tuto"
  echo " "

  echo "[Etape 1/5] K8S est en train de chauffer"
  
  # this script is in the path of the image for katacoda
  launch.sh
  
  while true; do
    kubectl version &> /dev/null
    if [[ "$?" -ne 0 ]]; then
      sleep "${delay}"
    else
      break
    fi
  done

  echo ""
  echo "[Etape 2/5] Les noeuds rejoignent le cluster K8S"
  echo -n " "

  kubectl wait --for=condition=Ready nodes --all --timeout=120s

  #  ===================== Create the NGINX Ingress ==========================
  echo "[Etape 3/5] Déploiement des CRDs de l'ingress Nginx"
  echo " "

  kubectl create namespace ingress-nginx

  /assets/00.install_helm.sh


  if [[ "$(kubectl version --output=json | jq ".serverVersion.minor" -r)" < "19" ]]; then
    helm upgrade --install ingress-nginx ingress-nginx \
      --repo https://kubernetes.github.io/ingress-nginx \
      --namespace ingress-nginx --version='<4'
  else
    helm upgrade --install ingress-nginx ingress-nginx \
      --repo https://kubernetes.github.io/ingress-nginx \
      --namespace ingress-nginx
  fi

  # ===================== Create the K8S namespace ==========================
  echo -e "[Etape 4/5] Création du namespace dédié au tuto\n\n"
  kubectl create namespace "${NAMESPACE}"

  # ===================== Installation of the Argo-Rollouts CRD ==========================

  echo -e "[Etape 5/5] Installation de l'interface Argo-rollouts \n\n"
 
  # Install the Dashboard - should be installed in the current namespace
  kubectl apply -f https://github.com/argoproj/argo-rollouts/releases/download/${ARGO_VERSION}/dashboard-install.yaml

  # Wait for ingress to be available
  kubectl wait --namespace ingress-nginx \
    --for=condition=ready pod \
    --selector=app.kubernetes.io/component=controller \
    --timeout=120s

  # Install the ingress
  kubectl apply -f "$(dirname $0)/00.global-components/"
  

  echo "Paramétrage effectué, paré au lancement"
  echo ""
}

show_progress
