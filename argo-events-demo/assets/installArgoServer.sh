#/bin/bash

kubectl create namespace ingress-nginx

helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --version='<4'

wget -q https://raw.githubusercontent.com/argoproj/argo-workflows/master/manifests/base/argo-server/argo-server-sa.yaml

kubectl apply -f argo-server-sa.yaml

cat << EOF > deployment.yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: argo-server
spec:
  selector:
    matchLabels:
      app: argo-server
  template:
    metadata:
      labels:
        app: argo-server
    spec:
      serviceAccountName: argo-server
      containers:
        - name: argo-server
          image: quay.io/argoproj/argocli:latest
          securityContext:
            capabilities:
              drop:
                - ALL
          args: [ server ]
          env:
          #- name: BASE_HREF
          #  value: /argo/
          ports:
            - name: web
              containerPort: 2746
          readinessProbe:
            httpGet:
              port: 2746
              scheme: HTTPS
              path: /
            initialDelaySeconds: 10
            periodSeconds: 20
          volumeMounts:
            - mountPath: /tmp
              name: tmp
      volumes:
        - name: tmp
          emptyDir: { }
      securityContext:
        runAsNonRoot: true
      nodeSelector:
        kubernetes.io/os: linux
EOF

kubectl apply -f deployment.yaml

wget -q https://raw.githubusercontent.com/argoproj/argo-workflows/master/manifests/base/argo-server/argo-server-service.yaml

kubectl apply -f argo-server-service.yaml

cat << EOF > ingress.yaml
---
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: argo-server
  annotations:
    ingress.kubernetes.io/rewrite-target: /$2
    nginx.ingress.kubernetes.io/backend-protocol: https # ingress-nginx
spec:
  rules:
    - http:
        paths:
          - backend:
              serviceName: argo-server
              servicePort: 2746
            #path: /argo(/|$)(.*)
            path: /
EOF

kubectl apply -f ingress.yaml
