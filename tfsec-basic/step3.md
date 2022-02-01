# Corriger le problème

Ouvrez dans un nouvel onglet le lien de la documentation TFSec : <a href="https://aquasecurity.github.io/tfsec/v1.0.2/checks/aws/kms/auto-rotate-keys/" target="_blank">Documentation TFSec - aws/kms/auto-rotate-keys</a>

Vous y obtenez de nombreuses informations, dont le moyen de corriger le problème détecté.

![Secure Example]](assets/secure-example.png)

Corrigez le problème :
`sed -i 's/\#FIXIT/enable_key_rotation     = true/' main.tf`{{execute}}
