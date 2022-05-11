#/bin/bash
helm repo add gitea-charts https://dl.gitea.io/charts/ >> /root/background.log

# helm repo add runatlantis https://runatlantis.github.io/helm-charts >> /root/background.log

helm repo update >> /root/background.log

helm install gitea gitea-charts/gitea

# helm install atlantis runatlantis/atlantis

sleep 5;
