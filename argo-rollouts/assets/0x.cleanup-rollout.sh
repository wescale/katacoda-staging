#!/bin/bash

# cleanup current Rollout
kubectl delete Rollout --all

# note: the "done" is necessary for the script to work.
echo "done" 
exit 0
