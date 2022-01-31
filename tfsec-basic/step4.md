# Corriger le problème - alternative

Pour corriger le problème, vous auriez aussi pu l'ignorer.

Pour ignorer un problème dans tfsec il suffit d'ajouter `tfsec:ignore:<nom_du_probleme>` au-dessus de la ressource incriminée.

Le fichier a été réinitialisé à l'état d'origine. Corrigez le problème en l'ignorant :
`sed -i '1i #tfsec:ignore:aws-kms-auto-rotate-keys' main.tf`{{execute}}

> **NB** : Bien entendu, la bonne solution est de corriger les problèmes, pas de les ignorer !
> Certaines recommandations de TFSec ne sont pas compatibles avec certains contextes, d'où l'utilité de cette option. 