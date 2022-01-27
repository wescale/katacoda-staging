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
  export NODE_IP=$(kubectl get node --selector='!node-role.kubernetes.io/master' -o jsonpath={.items[*].status.addresses[?\(@.type==\"InternalIP\"\)].address})
  ssh $NODE_IP 'mkdir -p /root/.kube'
  scp /root/.kube/config $NODE_IP:/root/.kube/config
  echo "K8S Ready"
}

show_progress
