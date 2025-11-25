#!/usr/bin/env bash
# Connect to the Rust development pod

NAMESPACE="lumuscar-jobs"
POD_NAME="dev-rust"

echo "Connecting to $POD_NAME in namespace $NAMESPACE..."
kubectl exec -it -n "$NAMESPACE" "$POD_NAME" -- /bin/bash
