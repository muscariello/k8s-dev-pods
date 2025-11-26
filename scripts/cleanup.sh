#!/usr/bin/env bash
# Delete all development pods and PVCs

set -e

NAMESPACE="lumuscar-jobs"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PODS_DIR="$(dirname "$SCRIPT_DIR")/pods"

echo "Cleaning up development environment from namespace: $NAMESPACE"
echo "=================================================="

# Delete pods
echo ""
echo "Deleting pods..."
kubectl delete -f "$PODS_DIR/dev-rust.yaml" --ignore-not-found=true
kubectl delete -f "$PODS_DIR/dev-go.yaml" --ignore-not-found=true
kubectl delete -f "$PODS_DIR/dev-python.yaml" --ignore-not-found=true
kubectl delete -f "$PODS_DIR/dev-js.yaml" --ignore-not-found=true
kubectl delete -f "$PODS_DIR/dev-all.yaml" --ignore-not-found=true

# Delete PVCs (WARNING: This will delete all workspace data!)
echo ""
read -p "Delete PVCs? This will PERMANENTLY delete all workspace data! (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Deleting PVCs..."
    kubectl delete -f "$PODS_DIR/pvc.yaml" --ignore-not-found=true
    echo "PVCs deleted."
else
    echo "Keeping PVCs. Your workspace data is preserved."
fi

echo ""
echo "=================================================="
echo "Cleanup complete!"
