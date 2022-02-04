Il existe plusieurs façons d'installer **TFSec** (brew,choco, scoop). Pour ce tutoriel nous allons directement télécharger le binaire.

# Installer le binaire TFSec

Téléchargez le binaire de TFSec et accordez lui les droits d'exécution :
`curl -o /usr/local/bin/tfsec -L -J -O https://github.com/aquasecurity/tfsec/releases/download/v1.0.2/tfsec-linux-amd64 && chmod u+x /usr/local/bin/tfsec`{{execute}}

Vérifiez que TFSec est bien installé :
`tfsec --version`{{execute}}

Vous devriez obtenir :
```
$ tfsec --version
v1.0.2
```
