Maintenant que nous avons installé TFSec nous allons pouvoir le tester. Pour cela il nous un bout de code Terraform à analyser.

# Utiliser TFSec

Un fichier `main.tf` contenant une ressource Terraform `aws_kms_key` a été créé :

`cat main.tf`{{execute}}

Testez la sécurité de l'infrastructure décrite avec TFSec :
`tfsec .`{{execute}}

# Analyser le résultat

Explicitons le retour obtenu :

- `MEDIUM` : Niveau de sévérité du problème détecté, il peut être soit LOW/MEDIUM/HIGH/CRITICAL
- `Key does not have rotation enabled` : Description du problème détecté
- `main.tf [...]` : Affichage du fichier et de la ressource incriminée
- `ID` : Identifiant unique du problème détecté
- `Impact` : Explication des impacts du problème
- `Resolution` : Proposition de correction du problème
- `More information` : Liens utiles permettant de mieux comprendre et corriger le problème. On y trouvera en général au moins les liens de documentations de TFSec et Terraform
- `timings` : Informations additionnelles des performances d'exécution de TFSec
- `1 potential problem(s) detected.` : Sommaire des résultats découverts par TFSec

