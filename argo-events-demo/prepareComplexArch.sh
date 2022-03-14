#/bin/bash

docker pull rg.fr-par.scw.cloud/katacoda/flask-argo:1.0.15
docker pull rg.fr-par.scw.cloud/katacoda/url-downloader:1.0.16
docker pull rg.fr-par.scw.cloud/katacoda/tesseract:1.0.5

kubectl apply -f deployment-flask.yaml

touch /root/prepareCompleArchDone.txt
