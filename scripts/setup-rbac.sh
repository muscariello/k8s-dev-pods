#!/usr/bin/env bash
# Apply RBAC configuration for dev-pods management

set -e

if [ "$#" -gt 0 ]; then
    NAMESPACES=("$@")
else
    NAMESPACES=("lumuscar-jobs" "lumuscar-spire")
fi
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RBAC_DIR="$(dirname "$SCRIPT_DIR")/rbac"

echo "Applying RBAC configuration..."
echo "========================================================"

for NAMESPACE in "${NAMESPACES[@]}"; do
    echo "Processing namespace: $NAMESPACE"
    
    # Check if namespace exists
    if ! kubectl get namespace "$NAMESPACE" &> /dev/null; then
        echo "Warning: Namespace $NAMESPACE does not exist."
        echo "Creating namespace..."
        kubectl create namespace "$NAMESPACE"
    fi

    # Apply Role
    echo "Creating Role: dev-pods-manager in $NAMESPACE"
    kubectl apply -f "$RBAC_DIR/role.yaml" -n "$NAMESPACE"

    # Apply RoleBinding
    echo "Creating RoleBinding: dev-pods-manager-binding in $NAMESPACE"
    kubectl apply -f "$RBAC_DIR/rolebinding.yaml" -n "$NAMESPACE"
    echo "--------------------------------------------------------"
done

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
for ns in "${NAMESPACES[@]}"; do
    echo "  kubectl get role -n $ns"
    echo "  kubectl get rolebinding -n $ns"
done
echo "  kubectl get clusterrole namespace-reader"
echo "  kubectl get clusterrolebinding namespace-reader-binding"
echo ""
echo "Test permissions with:"
for ns in "${NAMESPACES[@]}"; do
    echo "  # Permissions in $ns"
    echo "  kubectl auth can-i get pods -n $ns"
    echo "  kubectl auth can-i create pods -n $ns"
    echo ""
done
echo "  # Read-only access to other namespaces"
echo "  kubectl auth can-i get pods --all-namespaces"
echo "  kubectl auth can-i list namespaces"
