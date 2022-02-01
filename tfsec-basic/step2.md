# Tester TFSec

Maintenant que nous avons installé TFSec nous allons pouvoir le tester !

## Utiliser TFSec

Créez un fichier `main.tf` contenant une ressource Terraform `aws_kms_key` :

```sh
cat << EOF > ./main.tf
resource "aws_kms_key" "this" {
  description             = "Je suis une clé KMS"
  deletion_window_in_days = 10
  #FIXIT
}
EOF
```{{execute}}

Utilisez TFSec :
`tfsec .`{{execute}}

## Analyser le résultat

Explicitons le retour obtenu :

![Result Part 1]](assets/result-p1.png)
- `MEDIUM` : Niveau de sévérité du problème détecté, il peut être soit LOW/MEDIUM/HIGH/CRITICAL
- `Key does not have rotation enabled` : Description du problème détecté

![Result Part 2]](assets/result-p2.png)
- Affichage du fichier et de la ressource incriminé

![Result Part 3]](assets/result-p3.png)
- `ID` : Identifiant unique du problème détecté
- `Impact` : Explication des impacts du problème
- `Resolution` : Proposition de correction du problème

![Result Part 4]](assets/result-p4.png)
- `More information` : Liens utiles permettant de mieux comprendre et corriger le problème. On y trouvera en général au moins les liens de documentations de TFSec et Terraform

![Result Part 5]](assets/result-p5.png)
- Informations additionnelles des performances exécution de TFSec
- Sommaire des résultats découverts par TFSec

