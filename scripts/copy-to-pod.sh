#!/usr/bin/env bash
# Copy local workspace code to a development pod

set -e

NAMESPACE="lumuscar-jobs"

# Function to display usage
usage() {
    echo "Usage: $0 <pod-name> <local-path> [remote-path]"
    echo ""
    echo "Arguments:"
    echo "  pod-name      Name of the pod (dev-rust, dev-go, dev-python, dev-js)"
    echo "  local-path    Local directory or file to copy"
    echo "  remote-path   Remote path in pod (default: /workspace/)"
    echo ""
    echo "Examples:"
    echo "  $0 dev-rust /Users/me/myproject"
    echo "  $0 dev-go ./mycode /workspace/mycode"
    echo "  $0 dev-python ~/projects/app /workspace/app"
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
    dev-rust|dev-go|dev-python|dev-js)
        ;;
    *)
        echo "Error: Invalid pod name '$POD_NAME'"
        echo "Valid names: dev-rust, dev-go, dev-python, dev-js"
        exit 1
        ;;
esac

# Check if local path exists
if [ ! -e "$LOCAL_PATH" ]; then
    echo "Error: Local path '$LOCAL_PATH' does not exist"
    exit 1
fi

# Check if pod is running
POD_STATUS=$(kubectl get pod -n "$NAMESPACE" "$POD_NAME" -o jsonpath='{.status.phase}' 2>/dev/null || echo "NotFound")
if [ "$POD_STATUS" != "Running" ]; then
    echo "Error: Pod '$POD_NAME' is not running (status: $POD_STATUS)"
    echo "Deploy the pods first with: ./scripts/deploy.sh"
    exit 1
fi

echo "Copying '$LOCAL_PATH' to '$POD_NAME:$REMOTE_PATH'..."
echo ""

# Perform the copy
kubectl cp "$LOCAL_PATH" "$NAMESPACE/$POD_NAME:$REMOTE_PATH"

echo ""
echo "Copy complete!"
echo ""
echo "To verify, connect to the pod:"
echo "  ./scripts/shell-${POD_NAME#dev-}.sh"
echo ""
echo "Then check:"
echo "  ls -la $REMOTE_PATH"
