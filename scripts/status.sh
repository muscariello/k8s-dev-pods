#!/usr/bin/env bash
# Show status of all development pods

NAMESPACE="${1:-${NAMESPACE:-lumuscar-jobs}}"

echo "Development Pods Status"
echo "======================="
kubectl get pods -n "$NAMESPACE" -l type=development -o wide

echo ""
echo "PVCs Status"
echo "==========="
kubectl get pvc -n "$NAMESPACE" | grep "dev-.*-workspace"

echo ""
echo "Resource Usage"
echo "=============="
kubectl top pods -n "$NAMESPACE" -l type=development 2>/dev/null || echo "Metrics server not available"
