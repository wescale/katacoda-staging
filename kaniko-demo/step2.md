# La méthode qui échoue

Généralement, la construction d'images se fait au sein de l'intégration continue, et non pas localement.
La méthode classique consiste à utiliser un Worker, piloté par la CI, qui héberge le démon Docker. On se retrouve donc dans un cas similaire à celui d'une construction locale, et tout fonctionne comme attendu.

Mais a-t-on vraiment besoin d'une autre machine, d'une autre infrastructure, quand notre but est de déployer sur un cluster K8S ? Ne pourrait-on pas plutôt utiliser les ressources à notre disposition pour faire le build ?

D'ailleurs, Docker propose une image officielle... *docker* ! Utilisons là pour construire notre image directement sur K8S !

En premier lieu, nous allons déployer un pod qui contient l'image *docker*, et un simple *sleep* pour que la tâche ne se termine pas immédiatement :
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
```{{execute HOST2}}

et nous l'exécutons sur notre cluster :

`kubectl apply -f docker.yaml`{{execute HOST2}}

Le conteneur démarre, attendons qu'il soit disponible :
`kubectl wait --timeout=90s --for condition=containersready pod docker`{{execute HOST1}}

Exécutons un shell dans le conteneur :
`kubectl exec -ti docker -- sh`{{execute HOST2}}

et construisons notre image comme nous l'avons fait à l'étape précédente :
```sh
cd /tmp
cat << EOF > Dockerfile
FROM alpine
CMD ["/bin/echo", "\u001b[31mIt is alive !!!\u001b[m\r\n"]
EOF
docker build -t my-super-image .
```{{execute HOST2}}

Cela conduit à une erreur. Pourquoi ? Parce que le démon Docker ne s'exécute pas dans le conteneur. Celui ci contient seulement la CLI.

⚠️ Quittons le conteneur (en tapant ```sh #/tmp/```<kbd>exit</kbd>) ⚠️

🚩 N'oubliez pas cette étape, sinon le reste du scénario sera dysfonctionnel.

 et supprimons le pod :
```sh
kubectl delete -f docker.yaml && clear
```{{execute HOST2}}
