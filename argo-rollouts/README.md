# Argo-rollouts

This is the scenario created to emulate argo-rollouts.

To access the dashboard : 
kubectl port-forward svc/argo-rollouts-dashboard -n argo-rollouts 80:3100 --address='0.0.0.0' &