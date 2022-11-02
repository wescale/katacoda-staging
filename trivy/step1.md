Il existe plusieurs façons d'installer **Trivy** : gestionnaire de paquets, brew, MacPorts, Docker, les binaires, etc. Pour ce tutoriel nous allons directement télécharger le binaire.

# Installer Trivy via un gestionnaire de paquet

Téléchargez les dépendances nécessaires:

`sudo apt-get -y install wget apt-transport-https gnupg lsb-release`{{execute}}

Téléchargez et installez la clé GPG du repo `Trivy`:

`wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null`{{execute}}

Ajoutez Trivy comme source pour `apt`:

`echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list`{{execute}}

Mettez à jour le repo et installez `Trivy`:

`sudo apt-get update && sudo apt-get install trivy`{{execute}}

Vérifiez que `Trivy` est bien installé :

`trivy --version`{{execute}}

Vous devriez obtenir :
```
$ trivy --version
Version: 0.33.0
```
