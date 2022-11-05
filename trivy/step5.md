# Trouver des secrets

Par défaut, **chaque** scan Trivy tente de détecter des secrets. Que cela soit un scan d'image, de fichiers IaC ou autre.

Pour rappel, un **secret**, c'est une information sensible qui permet d'accéder à un système confidentiel. Que ce soit un Token, une clé API ou encore un mot de passe.

Faisons un test de détection de détection de secrets avec le scan de système de fichiers (fs) sur un dossier local, par hasard, celui de l'étape précédente:

`trivy fs ./fs-scan`{{execute}}

>**NB**: On peut remarquer que Trivy a la gentillesse de masquer les secrets dans son output. :) 

## Note sur la détectabilité d'un secret

Trivy possède une liste de règles intégrées pour détecter ou ignorer (notamment dans le cas d'exemples) des secrets.

Par exemple, notre scan n'a pas détecté ces mêmes identifiants dans le fichier `README.md`.

`cat ./fs-scan/README.md`{{execute}}

Vous pouvez activer ou désactiver (exclusif, la désactivation domine) des règles Trivy de détection des secrets grâce au drapeau `--secret-config` qui a pour argument un fichier de configuration.

### Liste blanche

Vous pouvez spécifier les règles à prendre en compte, et uniquement celles-ci.

Créez le fichier de configuration:

```plain
cat <<EOF> ./config/enable.yaml
enable-builtin-rules:
  - aws-access-key-id
EOF
```{{execute}}

Testez:

`trivy fs --secret-config ./config/enable.yaml fs-scan`{{execute}}

Trivy ne détecte plus notre clé secrète AWS comme un secret.

### Liste noire

Vous pouvez spécifier les règles à exclure.

Créez le fichier de configuration:

```plain
cat <<EOF> ./config/disable.yaml
disable-rules:
  - aws-access-key-id
  - aws-secret-access-key
  - aws-account-id
disable-allow-rules:
  - markdown
EOF
```{{execute}}

Testez:

`trivy fs --secret-config ./config/disable.yaml fs-scan`{{execute}}

Trivy ne détecte plus de secrets.

## Désactiver le scan de secrets

Vous pouvez désactiver le scan des secrets avec le drapeau `--security-checks`. Par défaut est défini avec la liste "vuln,secret" et accepte les paramètres suivants : "vuln,config,secret".

`trivy fs --security-checks vuln ./fs-scan`{{execute}}

>**NB**: Désactiver les secrets est une solution pour accélerer de manière notable la rapidité des scans Trivy. Évidemment, ce choix dépend de votre contexte.

## Documentations associées

- Documentation officielle: https://aquasecurity.github.io/trivy/v0.34/docs/secret/scanning/
- Règle de détection des secrets: https://github.com/aquasecurity/trivy/blob/main/pkg/fanal/secret/builtin-rules.go
- Règle d'autorisation des secrets: https://github.com/aquasecurity/trivy/blob/main/pkg/fanal/secret/builtin-allow-rules.go
- Recommandations pour accélerer la détection de secrets: https://aquasecurity.github.io/trivy/v0.34/docs/secret/scanning/#recommendation