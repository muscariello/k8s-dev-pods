#!/bin/bash
# Grant RW access (edit role) to a user for all namespaces matching a pattern
#
# Usage:
#   ./grant-wildcard-access.sh <username> [pattern]
#
# Example:
#   ./grant-wildcard-access.sh janedoe "lumuscar-*"

set -e

USER=$1
PATTERN=${2:-"lumuscar-*"}

if [ -z "$USER" ]; then
    echo "Usage: $0 <username> [namespace-pattern]"
    echo "Example: $0 janedoe \"lumuscar-*\""
    exit 1
fi

echo "Granting RW access (ClusterRole: edit) to user '$USER' for namespaces matching '$PATTERN'..."

# Get all namespaces and filter by pattern
kubectl get ns --no-headers -o custom-columns=":metadata.name" | while read ns; do
    # shellcheck disable=SC2053
    if [[ "$ns" == $PATTERN ]]; then
        echo "Processing namespace: $ns"
        
        # Create RoleBinding
        # We use apply with dry-run to make it idempotent
        kubectl create rolebinding "${USER}-edit-access" \
            --clusterrole=edit \
            --user="$USER" \
            --namespace="$ns" \
            --dry-run=client -o yaml | kubectl apply -f -
            
        echo "  - Created/Updated RoleBinding '${USER}-edit-access' in '$ns'"
    fi
done

echo "Done."
