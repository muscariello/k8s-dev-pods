#!/usr/bin/env bash
# Connect to the Go development pod

NAMESPACE="lumuscar-jobs"
POD_NAME="dev-go"

echo "Connecting to $POD_NAME in namespace $NAMESPACE..."
kubectl exec -it -n "$NAMESPACE" "$POD_NAME" -- /bin/bash
