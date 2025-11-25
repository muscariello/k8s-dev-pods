#!/usr/bin/env bash
# Apply RBAC configuration for dev-pods management

set -e

NAMESPACE="lumuscar-jobs"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RBAC_DIR="$(dirname "$SCRIPT_DIR")/rbac"

echo "Applying RBAC configuration for namespace: $NAMESPACE"
echo "========================================================"

# Check if namespace exists
if ! kubectl get namespace "$NAMESPACE" &> /dev/null; then
    echo "Warning: Namespace $NAMESPACE does not exist."
    echo "Creating namespace..."
    kubectl create namespace "$NAMESPACE"
fi

# Apply Role
echo ""
echo "Creating Role: dev-pods-manager"
kubectl apply -f "$RBAC_DIR/role.yaml"

# Apply RoleBinding
echo ""
echo "Creating RoleBinding: dev-pods-manager-binding"
echo "Note: Make sure to edit rbac/rolebinding.yaml with the correct user/serviceaccount/group"
kubectl apply -f "$RBAC_DIR/rolebinding.yaml"

# Apply ClusterRole for read-only access to other namespaces
echo ""
echo "Creating ClusterRole: namespace-reader"
kubectl apply -f "$RBAC_DIR/clusterrole-reader.yaml"

# Apply ClusterRoleBinding
echo ""
echo "Creating ClusterRoleBinding: namespace-reader-binding"
echo "Note: Make sure to edit rbac/clusterrolebinding-reader.yaml with the correct user/serviceaccount/group"
kubectl apply -f "$RBAC_DIR/clusterrolebinding-reader.yaml"

echo ""
echo "========================================================"
echo "RBAC configuration applied successfully!"
echo ""
echo "Verify with:"
echo "  kubectl get role -n $NAMESPACE"
echo "  kubectl get rolebinding -n $NAMESPACE"
echo "  kubectl get clusterrole namespace-reader"
echo "  kubectl get clusterrolebinding namespace-reader-binding"
echo ""
echo "Test permissions with:"
echo "  # Permissions in $NAMESPACE"
echo "  kubectl auth can-i get pods -n $NAMESPACE"
echo "  kubectl auth can-i create pods -n $NAMESPACE"
echo "  kubectl auth can-i exec pods -n $NAMESPACE"
echo ""
echo "  # Read-only access to other namespaces"
echo "  kubectl auth can-i get pods --all-namespaces"
echo "  kubectl auth can-i list namespaces"
