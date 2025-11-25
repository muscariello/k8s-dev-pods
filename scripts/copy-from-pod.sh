#!/usr/bin/env bash
# Copy code from a development pod to local workspace

set -e

NAMESPACE="lumuscar-jobs"

# Function to display usage
usage() {
    echo "Usage: $0 <pod-name> <remote-path> [local-path]"
    echo ""
    echo "Arguments:"
    echo "  pod-name      Name of the pod (dev-rust, dev-go, dev-python, dev-js)"
    echo "  remote-path   Path in pod to copy from"
    echo "  local-path    Local destination (default: current directory)"
    echo ""
    echo "Examples:"
    echo "  $0 dev-rust /workspace/myproject"
    echo "  $0 dev-go /workspace/mycode ./mycode"
    echo "  $0 dev-python /workspace/app ~/projects/app"
    exit 1
}

# Check arguments
if [ $# -lt 2 ]; then
    usage
fi

POD_NAME="$1"
REMOTE_PATH="$2"
LOCAL_PATH="${3:-.}"

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

# Check if pod is running
POD_STATUS=$(kubectl get pod -n "$NAMESPACE" "$POD_NAME" -o jsonpath='{.status.phase}' 2>/dev/null || echo "NotFound")
if [ "$POD_STATUS" != "Running" ]; then
    echo "Error: Pod '$POD_NAME' is not running (status: $POD_STATUS)"
    exit 1
fi

echo "Copying '$POD_NAME:$REMOTE_PATH' to '$LOCAL_PATH'..."
echo ""

# Perform the copy
kubectl cp "$NAMESPACE/$POD_NAME:$REMOTE_PATH" "$LOCAL_PATH"

echo ""
echo "Copy complete!"
echo ""
echo "Files copied to: $LOCAL_PATH"
