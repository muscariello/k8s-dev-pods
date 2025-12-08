#!/usr/bin/env bash
# Sync local workspace code to a development pod using rsync

set -e

NAMESPACE="${NAMESPACE:-lumuscar-jobs}"

# Function to display usage
usage() {
    echo "Usage: $0 <pod-name> <local-path> [remote-path]"
    echo ""
    echo "Sync local directory to pod using rsync (requires rsync in pod)"
    echo ""
    echo "Arguments:"
    echo "  pod-name      Name of the pod (dev-rust, dev-go, dev-python, dev-js, dev-all)"
    echo "  local-path    Local directory to sync"
    echo "  remote-path   Remote path in pod (default: /workspace/)"
    echo ""
    echo "Examples:"
    echo "  $0 dev-rust /Users/me/myproject"
    echo "  $0 dev-go ./mycode /workspace/mycode"
    echo ""
    echo "Note: This uses kubectl exec + tar for efficient directory sync"
    exit 1
}

# Check arguments
if [ $# -lt 2 ]; then
    usage
fi

POD_NAME="$1"
LOCAL_PATH="$2"
REMOTE_PATH="${3:-/workspace/}"

# Validate pod name
case "$POD_NAME" in
    dev-rust|dev-go|dev-python|dev-js|dev-all)
        ;;
    *)
        echo "Error: Invalid pod name '$POD_NAME'"
        echo "Valid names: dev-rust, dev-go, dev-python, dev-js, dev-all"
        exit 1
        ;;
esac

# Check if local path exists and is a directory
if [ ! -d "$LOCAL_PATH" ]; then
    echo "Error: Local path '$LOCAL_PATH' is not a directory"
    exit 1
fi

# Check if pod is running
POD_STATUS=$(kubectl get pod -n "$NAMESPACE" "$POD_NAME" -o jsonpath='{.status.phase}' 2>/dev/null || echo "NotFound")
if [ "$POD_STATUS" != "Running" ]; then
    echo "Error: Pod '$POD_NAME' is not running (status: $POD_STATUS)"
    echo "Deploy the pods first with: ./scripts/deploy.sh"
    exit 1
fi

echo "Syncing '$LOCAL_PATH' to '$POD_NAME:$REMOTE_PATH'..."
echo ""

# Create remote directory if it doesn't exist
kubectl exec -n "$NAMESPACE" "$POD_NAME" -- mkdir -p "$REMOTE_PATH"

# Sync using tar (more efficient than kubectl cp for directories)
tar czf - -C "$LOCAL_PATH" . | kubectl exec -i -n "$NAMESPACE" "$POD_NAME" -- tar xzf - -C "$REMOTE_PATH"

echo ""
echo "Sync complete!"
echo ""
echo "To verify, connect to the pod:"
echo "  ./scripts/shell-${POD_NAME#dev-}.sh"
echo ""
echo "Then check:"
echo "  ls -la $REMOTE_PATH"
