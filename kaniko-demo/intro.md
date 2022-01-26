# Construire des images de conteneurs directement sur Kubernetes, avec Kaniko

Kaniko est un outil open source, développé par Google (mais qui ne bénéficie pas de support officiel). Il permet de construire des images Docker, directement sur K8S, sans intergair directement avc le démon Docker et sans disposer de privilèges élevés.


## Description

Dans cette démonstration, nous illustrerons les différentes manières de constuire une image Docker simple, en partant d'un build classique sur le poste de travail de l'utilisateur, et en le déplacant progressivement vers le cluster K8S.
De cette manière, il n'est pas nécessaire de disposer de machines tierces pour effectuer les tâches de CI / CD, et tout se passe au sein du cluster.

## Sommaire

- Construire une image localement
- Construire une image sur K8S, de la mauvaise manière
- Construire une image sur K8S, en utilisant Kaniko
