#!/bin/bash

POD_NAME="dev-all"
NAMESPACE="${1:-${NAMESPACE:-lumuscar-jobs}}"

echo "Connecting to $POD_NAME in namespace $NAMESPACE..."
kubectl exec -it -n $NAMESPACE $POD_NAME -- /bin/bash
