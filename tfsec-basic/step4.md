# Ignorer le problème

Pour ignorer un problème avec TFSec il suffit d'ajouter `tfsec:ignore:<nom_du_probleme>` au-dessus de la ressource incriminée.

> **NB** : Le fichier `main.tf` a automatiquement été réinitialisé à l'état d'origine.

Corrigez le problème en l'ignorant :
`sed -i '1i #tfsec:ignore:aws-kms-auto-rotate-keys' main.tf`{{execute}}

Regardez le contenu du fichier :
`cat main.tf`{{execute}}

Vérifiez que plus aucun problème n'est détecté :
`tfsec .`{{execute}}

> **NB** : Bien entendu, la bonne solution est de corriger les problèmes, pas de les ignorer !
> Parfois les recommandations de TFSec ne sont pas compatibles avec certains contextes, d'où l'utilité de cette option.