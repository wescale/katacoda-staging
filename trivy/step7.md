# Jouer avec la configuration

Comme la plupart des outils, vous pouvez utiliser un fichier pour configurer son comportement.

Vous pouvez exporter la configuration Trivy par défaut avec le drapeau `--generate-default-config`, ce qui générera un fichier `trivy-default.yaml`:

`trivy config --generate-default-config`{{execute}}

Vous pouvez constater les différentes configurations possible via ce fichier:

`cat trivy-default.yaml`{{execute}}

>**NB**: La configuration exportée est liée au type d'analyse que l'on souhaite effectuer, ici on exporte la configuration de l'analyse d'IaC mais cette option est valide pour tout type d'analyse.

Vous pouvez spécificer le fichier de configuration à utiliser avec le drapeau `--config`:

`trivy config --config ./trivy-default.yaml`{{execute}}
