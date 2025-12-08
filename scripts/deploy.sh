#!/usr/bin/env bash
# Deploy all development pods and PVCs

set -e

NAMESPACE="${1:-${NAMESPACE:-lumuscar-jobs}}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PODS_DIR="$(dirname "$SCRIPT_DIR")/pods"

# HTTP Proxy configuration
HTTP_PROXY="${HTTP_PROXY:-http://proxy-wsa.esl.cisco.com:80}"
HTTPS_PROXY="${HTTPS_PROXY:-http://proxy-wsa.esl.cisco.com:80}"
NO_PROXY="${NO_PROXY:-localhost,127.0.0.1,.svc,.cluster.local}"

echo "Deploying development environment to namespace: $NAMESPACE"
echo "Proxy: $HTTP_PROXY"
echo "=================================================="

# Create PVCs first
echo ""
echo "Creating PVCs..."
kubectl apply -f "$PODS_DIR/pvc.yaml"

# Wait a bit for PVCs to be bound
echo "Waiting for PVCs to be ready..."
sleep 5

# Deploy all pods
echo ""
echo "Deploying dev-rust pod..."
sed "s|value: \"http://proxy-wsa.esl.cisco.com:80\"|value: \"$HTTP_PROXY\"|g" "$PODS_DIR/dev-rust.yaml" | kubectl apply -f -

echo "Deploying dev-go pod..."
sed "s|value: \"http://proxy-wsa.esl.cisco.com:80\"|value: \"$HTTP_PROXY\"|g" "$PODS_DIR/dev-go.yaml" | kubectl apply -f -

echo "Deploying dev-python pod..."
sed "s|value: \"http://proxy-wsa.esl.cisco.com:80\"|value: \"$HTTP_PROXY\"|g" "$PODS_DIR/dev-python.yaml" | kubectl apply -f -

echo "Deploying dev-js pod..."
sed "s|value: \"http://proxy-wsa.esl.cisco.com:80\"|value: \"$HTTP_PROXY\"|g" "$PODS_DIR/dev-js.yaml" | kubectl apply -f -

echo "Deploying dev-all pod (all languages)..."
sed "s|value: \"http://proxy-wsa.esl.cisco.com:80\"|value: \"$HTTP_PROXY\"|g" "$PODS_DIR/dev-all.yaml" | kubectl apply -f -

echo ""
echo "=================================================="
echo "All pods deployed! They will take several minutes to initialize."
echo ""
echo "Check status with:"
echo "  kubectl get pods -n $NAMESPACE -l type=development"
echo ""
echo "Watch initialization progress:"
echo "  kubectl logs -f -n $NAMESPACE dev-rust"
echo "  kubectl logs -f -n $NAMESPACE dev-go"
echo "  kubectl logs -f -n $NAMESPACE dev-python"
echo "  kubectl logs -f -n $NAMESPACE dev-js"
echo "  kubectl logs -f -n $NAMESPACE dev-all"
echo ""
echo "Once running, connect to a pod:"
echo "  ./scripts/shell-rust.sh"
echo "  ./scripts/shell-go.sh"
echo "  ./scripts/shell-python.sh"
echo "  ./scripts/shell-js.sh"
echo "  ./scripts/shell-all.sh"
