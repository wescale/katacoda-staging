# Analyse d'image de conteneur

L'une des premières utilité de trivy est évidemment sa capacité à analyser une image de conteneur.
Analysons l'image latest de nginx:

`trivy image nginx:latest`{{execute}}

Par défaut il y a 4 colonnes :
- **Library**: Le nom de la librairie détectée comme vulnérable.
- **Vulnerability**: La vulnérabilité (**CVE***) associée à la librairie.
- **Severity**: La niveau de sévérité (**CVSS***) associé à la vulnérabilité.
- **Installed Version**: La version de la librairie détectée comme vulnérable.
- **Fixed Version**: La version de la librairie n'étant plus vulnérable/patchée.
- **Title**: Cette partie contient un très court extrait explicitant la vulnérabilité mais surtout un lien vers la "**Aqua vulnerability database**", une base de donnée de vulnérabilités d'Aqua Security. Elle contient tout ce qui a à savoir sur la vulnérabilité (nom, description, versions concernées, résolutions, etc.).

***CVE**: 

***CVSS**: 

Maintenant que nous comprenons mieux le résultat il est important de noter que même une image Nginx latest contient des paquets avec des vulnérabilités connues, même des critiques. D'où l'importance de sécuriser ses images et l'écosystème technique dans lequel elles évoluent.

# Exploiter les drapeaux

## Ignorer l'inutile

Il faut reconnaître que le résultat n'est pas forcément lisible tel quel et que les vulnérabilités faibles ne sont pas la priorité. On peut évidemment filtrer.

`trivy image nginx:latest --severity HIGH,CRITICAL --ignore-unfixed`{{execute}}

`--severity`: on peut filtrer les sévérités qui sont soit UNKNOWN,LOW,MEDIUM,HIGH,CRITICAL
`--ignore-unfixed`: permet d'ignorer les vulnérabilités qui n'ont pas de solutions connues. Evidemment une vulnérabilité critique, même sans solution, n'est pas à ignorer, mais ce drapeau a le mérite de permettre d'ignorer une partie du bruit.