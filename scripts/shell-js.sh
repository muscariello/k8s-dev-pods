#!/usr/bin/env bash
# Connect to the Node.js development pod

NAMESPACE="lumuscar-jobs"
POD_NAME="dev-js"

echo "Connecting to $POD_NAME in namespace $NAMESPACE..."
kubectl exec -it -n "$NAMESPACE" "$POD_NAME" -- /bin/bash
