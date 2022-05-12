#!/bin/bash
set -e

if kubectl get AnalysisTemplate linkchecker > /dev/null; then
  echo "done"
  exit 0
fi

echo "Apply the AnalysisTemplate to go to the next step !"
exit 1
