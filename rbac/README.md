# RBAC Configuration

This directory contains Kubernetes RBAC resources to enable non-admin users to work with development pods in the `lumuscar-jobs` and `lumuscar-spire` namespaces.

## Files

### Namespace-scoped (lumuscar-jobs, lumuscar-spire)

- **`role.yaml`**: Role granting full management permissions for pods and PVCs in `lumuscar-jobs` and `lumuscar-spire` namespaces
  - Pod: create, get, list, watch, update, patch, delete
  - Pod logs: get, list
  - Pod exec: create, get (for shell access and file sync)
  - PVC: create, get, list, watch, update, patch, delete
  - Metrics: get, list (if metrics-server available)

- **`rolebinding.yaml`**: Binds the `dev-pods-manager` role to users/service accounts
  - **Action Required**: Edit this file to specify your username, service account, or group

### Cluster-scoped (all namespaces)

- **`clusterrole-reader.yaml`**: ClusterRole granting read-only access across all namespaces
  - Namespaces: get, list, watch
  - Pods, Services, ConfigMaps, Secrets, PVCs, PVs, Nodes, Events: get, list, watch
  - Deployments, ReplicaSets, StatefulSets, DaemonSets: get, list, watch
  - Ingresses: get, list, watch
  - Metrics: get, list (if metrics-server available)

- **`clusterrolebinding-reader.yaml`**: Binds the `namespace-reader` ClusterRole to users/service accounts
  - **Action Required**: Edit this file to specify your username, service account, or group

## Setup Instructions

### 1. Edit the RoleBinding and ClusterRoleBinding

Before applying, edit the subject in both binding files:

**For a specific user:**
```yaml
subjects:
- kind: User
  name: your-username  # Replace with actual username
  apiGroup: rbac.authorization.k8s.io
```

**For a service account:**
```yaml
subjects:
- kind: ServiceAccount
  name: your-service-account
  namespace: lumuscar-jobs # or lumuscar-spire
```

**For a group:**
```yaml
subjects:
- kind: Group
  name: your-group-name
  apiGroup: rbac.authorization.k8s.io
```

### 2. Apply RBAC Configuration

Run the setup script with admin credentials:

```bash
# Using admin kubeconfig
export KUBECONFIG=/path/to/admin/kubeconfig
./scripts/setup-rbac.sh
```

Or apply manually (for each namespace):

```bash
# For lumuscar-jobs
kubectl apply -f rbac/role.yaml -n lumuscar-jobs
kubectl apply -f rbac/rolebinding.yaml -n lumuscar-jobs

# For lumuscar-spire
kubectl apply -f rbac/role.yaml -n lumuscar-spire
kubectl apply -f rbac/rolebinding.yaml -n lumuscar-spire

# Cluster-wide resources (apply once)
kubectl apply -f rbac/clusterrole-reader.yaml
kubectl apply -f rbac/clusterrolebinding-reader.yaml
```

### 3. Verify Permissions

Switch to your non-admin kubeconfig and test:

```bash
export KUBECONFIG=/path/to/gls-namespace/kubeconfig

# Test namespace-scoped permissions (lumuscar-jobs)
kubectl auth can-i create pods -n lumuscar-jobs           # Should be 'yes'
kubectl auth can-i delete pods -n lumuscar-jobs           # Should be 'yes'
kubectl auth can-i exec pods -n lumuscar-jobs             # Should be 'yes'
kubectl auth can-i create persistentvolumeclaims -n lumuscar-jobs  # Should be 'yes'

# Test namespace-scoped permissions (lumuscar-spire)
kubectl auth can-i create pods -n lumuscar-spire          # Should be 'yes'
kubectl auth can-i delete pods -n lumuscar-spire          # Should be 'yes'

# Test cluster-wide read permissions
kubectl auth can-i list namespaces                        # Should be 'yes'
kubectl auth can-i get pods --all-namespaces              # Should be 'yes'
kubectl auth can-i get pods -n other-namespace            # Should be 'yes'
kubectl auth can-i create pods -n other-namespace         # Should be 'no'
```

### 4. Use Development Scripts

Once RBAC is configured, all scripts in `scripts/` will work with the non-admin kubeconfig:

```bash
export KUBECONFIG=/path/to/gls-namespace/kubeconfig

# Deploy pods
./scripts/deploy.sh

# Check status
./scripts/status.sh

# Connect to pods
./scripts/shell-rust.sh
./scripts/shell-go.sh
./scripts/shell-python.sh
./scripts/shell-js.sh
./scripts/shell-all.sh

# Sync code
./scripts/sync-to-pod.sh dev-rust /path/to/code /workspace/code

# Cleanup
./scripts/cleanup.sh
```

## Permissions Summary

### In lumuscar-jobs and lumuscar-spire namespaces (Full Management)
- ✅ Create, update, delete pods
- ✅ Create, update, delete PVCs
- ✅ View pod logs
- ✅ Execute commands in pods (kubectl exec)
- ✅ View metrics

### In other namespaces (Read-Only)
- ✅ View namespaces
- ✅ View pods, services, deployments, etc.
- ✅ View pod logs
- ❌ Create, update, or delete resources
- ❌ Execute commands in pods

## Troubleshooting

### Permission Denied Errors

If you get permission errors:

1. Verify RBAC is applied:
   ```bash
   kubectl get role dev-pods-manager -n lumuscar-jobs
   kubectl get rolebinding dev-pods-manager-binding -n lumuscar-jobs
   # Also check lumuscar-spire
   kubectl get role dev-pods-manager -n lumuscar-spire
   kubectl get rolebinding dev-pods-manager-binding -n lumuscar-spire
   
   kubectl get clusterrole namespace-reader
   kubectl get clusterrolebinding namespace-reader-binding
   ```

2. Check the subject in the bindings matches your identity:
   ```bash
   kubectl get rolebinding dev-pods-manager-binding -n lumuscar-jobs -o yaml
   kubectl get clusterrolebinding namespace-reader-binding -o yaml
   ```

3. Verify your current identity:
   ```bash
   kubectl auth whoami
   ```

4. Test specific permissions:
   ```bash
   kubectl auth can-i <verb> <resource> -n <namespace>
   ```

### Common Issues

- **Subject mismatch**: Ensure the username/serviceaccount/group in the bindings matches your kubeconfig identity
- **Wrong context**: Make sure you're using the correct kubeconfig context
- **Namespace doesn't exist**: The lumuscar-jobs or lumuscar-spire namespace must exist before applying Role/RoleBinding
- **Cluster admin required**: You need cluster admin privileges to create ClusterRoles and ClusterRoleBindings

## Security Notes

- The `dev-pods-manager` role grants **full control** over pods and PVCs in the `lumuscar-jobs` namespace
- Pod exec permissions allow running arbitrary commands in pods
- The ClusterRole grants **read-only** access to resources across all namespaces
- Secrets are readable but this is often necessary for debugging; consider removing if not needed
- Adjust permissions as needed for your security requirements
