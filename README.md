# Kubernetes Development Pods

Permanent development pods for Rust, Go, Python, and Node.js in the `lumuscar-jobs` namespace.

## Overview

This repository contains Kubernetes configurations for five persistent development environments:

- **dev-rust**: Rust development with full toolchain (rust:1.90-bookworm)
- **dev-go**: Go development with common tools (golang:1.25-bookworm)
- **dev-python**: Python development with pyenv and common packages (python:3.13-bookworm)
- **dev-js**: Node.js development with npm/yarn/pnpm (node:22-bookworm)
- **dev-all**: All-in-one environment with Rust, Go, Python, and Node.js (buildpack-deps:bookworm)

Each pod has:
- 50Gi persistent workspace storage (ceph-block)
- HTTP proxy configuration for your enterprise proxy
- Full development toolchain for the respective language(s)
- Task 3.45.5 for build automation
- Resource limits: 8Gi request/32Gi limit RAM, 4/16 CPU cores

## Features

- **RBAC-enabled**: Works with non-admin kubeconfig (gls-namespace context)
- **Full management** in `lumuscar-jobs` namespace: create/delete pods, exec, logs
- **Read-only access** to all other namespaces
- **Persistent storage**: Workspace data survives pod restarts
- **Proxy-aware**: Pre-configured for your enterprise proxy
- **Fast initialization**: Uses buildpack-deps for dev-all pod (includes build tools)

## Prerequisites

### RBAC Configuration (First Time Setup)

Before deploying pods with a non-admin kubeconfig, set up RBAC permissions:

```bash
# Switch to admin kubeconfig
export KUBECONFIG=/path/to/admin/kubeconfig

# Apply RBAC configuration
./scripts/setup-rbac.sh

# Verify permissions
kubectl get role dev-pods-manager -n lumuscar-jobs
kubectl get clusterrole namespace-reader
```

This grants:
- **Full control** in `lumuscar-jobs` namespace (pods, PVCs, exec, logs)
- **Read-only access** to all other namespaces

See [rbac/README.md](rbac/README.md) for detailed RBAC documentation.

### Switch to Non-Admin Context

```bash
# Use non-admin kubeconfig
export KUBECONFIG=/path/to/gls-namespace/kubeconfig
kubectl config use-context gls-namespace

# Verify you're using the correct context
kubectl config current-context

# Test permissions
kubectl auth can-i create pods -n lumuscar-jobs  # Should be 'yes'
kubectl auth can-i get pods --all-namespaces     # Should be 'yes'
```

## Quick Start

### Deploy All Pods

```bash
# Deploy with default proxy configuration
./scripts/deploy.sh

# Or specify custom proxy
HTTP_PROXY=http://your-proxy:port ./scripts/deploy.sh
```

This will:
1. Create 5 PVCs (50Gi each) for workspace persistence
2. Deploy all 5 development pods (dev-rust, dev-go, dev-python, dev-js, dev-all)
3. Initialize each environment (takes 5-10 minutes for specialized pods, ~15 minutes for dev-all)

### Check Status

```bash
./scripts/status.sh
```

Or manually:

```bash
kubectl get pods -n lumuscar-jobs -l type=development
kubectl logs -f -n lumuscar-jobs dev-rust  # Watch initialization
```

### Connect to a Pod

```bash
./scripts/shell-rust.sh    # Rust environment
./scripts/shell-go.sh      # Go environment
./scripts/shell-python.sh  # Python environment
./scripts/shell-js.sh      # Node.js environment
./scripts/shell-all.sh     # All-in-one environment
```

Or manually:

```bash
kubectl exec -it -n lumuscar-jobs dev-rust -- /bin/bash
```

### Copy Code to Pods

**Copy a single file or directory:**
```bash
./scripts/sync-to-pod.sh dev-rust /Users/me/myproject /workspace/myproject
./scripts/sync-to-pod.sh dev-go ./mycode /workspace/mycode
./scripts/sync-to-pod.sh dev-all ~/Projects/slim /workspace/slim
```

**Sync entire directory (efficient for large projects):**
```bash
./scripts/sync-to-pod.sh dev-python ~/projects/myapp /workspace/myapp
```

**Copy code back from pod:**
```bash
./scripts/copy-from-pod.sh dev-rust /workspace/myproject ./myproject-backup
```

## Development Environments

### dev-rust (Rust 1.91.1)

**Base Image:** `rust:1.90-bookworm`

**Installed Tools:**
- Rust 1.91.1 stable toolchain with clippy, rustfmt, rust-analyzer
- Cross-compilation targets: x86_64-unknown-linux-gnu, aarch64-unknown-linux-gnu
- LLVM/Clang tools: clang, lld, lldb, llvm
- Cargo tools: cargo-watch, cargo-edit, cargo-outdated, cargo-audit
- Build tools: gcc, g++, make, cmake, pkg-config
- Libraries: libssl-dev, libicu-dev, libxml2-dev, libz3-dev
- Task 3.45.5 for build automation
- Editors: vim, nano, tmux, zsh

**Workspace:** `/workspace`
- `CARGO_HOME=/workspace/.cargo`
- `RUSTUP_HOME=/workspace/.rustup`

**Example Usage:**
```bash
./scripts/shell-rust.sh
cd /workspace
cargo new myproject
cd myproject
cargo build
cargo test
```

### dev-go (Go 1.25.4)

**Base Image:** `golang:1.25-bookworm`

**Installed Tools:**
- Go 1.25.4 with GOTOOLCHAIN=auto (automatic version management)
- gopls (language server)
- delve (debugger)
- staticcheck, goimports, golangci-lint
- Task 3.45.5 (build automation)
- Build tools: gcc, g++, make, protobuf-compiler, unzip
- Editors: vim, nano, tmux, zsh

**Workspace:** `/workspace`
- `GOPATH=/workspace/go`
- `GOBIN=/workspace/go/bin`

**Example Usage:**
```bash
./scripts/shell-go.sh
cd /workspace
mkdir myproject && cd myproject
go mod init myproject
# Start coding...
go build
go test ./...
```

### dev-python (Python 3.13)

**Base Image:** `python:3.13-bookworm`

**Installed Tools:**
- Python 3.13
- pyenv (for multiple Python versions)
- Testing: pytest, pytest-cov
- Linting: black, flake8, mypy, pylint
- Tools: ipython, jupyter, jupyterlab
- Libraries: requests, httpx, aiohttp, pandas, numpy, matplotlib
- Package managers: poetry, pipenv, pip
- Task 3.45.5 (build automation)
- Editors: vim, nano, tmux, zsh

**Workspace:** `/workspace`
- `PYTHONPATH=/workspace`
- `PYENV_ROOT=/workspace/.pyenv`

**Example Usage:**
```bash
./scripts/shell-python.sh
cd /workspace
mkdir myproject && cd myproject
python -m venv venv
source venv/bin/activate
# Start coding...
pytest
```

### dev-js (Node.js 22.21.0)

**Base Image:** `node:22-bookworm`

**Installed Tools:**
- Node.js v22.21.0, npm 10.9.4
- NVM v0.40.0 for version management
- TypeScript, ts-node, @types/node
- Linting: eslint, prettier
- Package managers: npm, yarn, pnpm
- Build tools: webpack, vite
- Process managers: nodemon, pm2
- Monorepo: nx
- Task 3.45.5 (build automation)
- Editors: vim, nano, tmux, zsh

**Workspace:** `/workspace`
- `NVM_DIR=/workspace/.nvm`

**Example Usage:**
```bash
./scripts/shell-js.sh
cd /workspace
mkdir myproject && cd myproject
npm init -y
npm install express
# Start coding...
npm test
```

**Switch Node versions:**
```bash
nvm install 18      # Install Node 18
nvm use 18          # Switch to Node 18
nvm alias default 18 # Set default
```

### dev-all (All Languages)

**Base Image:** `buildpack-deps:bookworm`

**Why buildpack-deps?** This image includes essential build tools (curl, wget, git, gcc, g++, make, cmake, pkg-config, libssl-dev, ca-certificates) pre-installed, significantly reducing initialization time from 105+ minutes to ~15 minutes compared to ubuntu:24.04 base.

**Installed Language Toolchains:**
- **Rust:** 1.91.1 stable with clippy, rustfmt, rust-analyzer
  - Additional targets: x86_64-unknown-linux-gnu, aarch64-unknown-linux-gnu
  - CARGO_HOME=/workspace/.cargo, RUSTUP_HOME=/workspace/.rustup
- **Go:** 1.25.4 with gopls, delve, staticcheck, goimports, golangci-lint
  - GOTOOLCHAIN=auto, GOPATH=/workspace/go, GOBIN=/workspace/go/bin
- **Node.js:** v22.21.0 with npm 10.9.4, TypeScript, ESLint, Prettier, yarn, pnpm
  - NVM_DIR=/workspace/.nvm
- **Python:** 3.11.2 with pytest, black, flake8, mypy, jupyter, pandas, numpy
  - PYTHONPATH=/workspace, PYENV_ROOT=/workspace/.pyenv

**Additional Tools:**
- LLVM/Clang: clang-19, lldb, lld, llvm (required for Rust builds)
- Task 3.45.5 for build automation
- protobuf-compiler, unzip
- Editors: vim, nano, tmux, zsh

**Workspace:** `/workspace`

**Best For:** Multi-language projects requiring Rust + Go + Python + Node.js (e.g., SLIM project with Rust data-plane and Go control-plane)

**Example Usage:**
```bash
./scripts/shell-all.sh
cd /workspace

# Build Rust project
cd myrust-project
cargo build --release

# Build Go project
cd ../mygo-project
go build -o app

# Run Python scripts
python3 myscript.py

# Run Node.js app
node server.js
```

**SLIM Project Example:**
```bash
# Sync SLIM project to dev-all
./scripts/sync-to-pod.sh dev-all ~/Projects/slim /workspace/slim

# Connect to pod
./scripts/shell-all.sh

# Fix git ownership
git config --global --add safe.directory /workspace/slim

# Build Rust data-plane
cd /workspace/slim/data-plane
task data-plane:build

# Build Go control-plane
cd /workspace/slim/control-plane
task control-plane:build
```

## Network Configuration

All pods are configured with HTTP proxy for your enterprise proxy:

```yaml
env:
  - name: HTTP_PROXY
    value: "http://proxy.example.com:80"
  - name: HTTPS_PROXY
    value: "http://proxy.example.com:80"
  - name: NO_PROXY
    value: "localhost,127.0.0.1,.svc,.cluster.local"
```

This is applied to:
- Container environment variables
- apt-get (inherits from env)
- Language-specific package managers (cargo, go, pip, npm)

## Persistent Storage

Each pod has a dedicated 50Gi PVC:
- `dev-rust-workspace` → `/workspace` in dev-rust
- `dev-go-workspace` → `/workspace` in dev-go
- `dev-python-workspace` → `/workspace` in dev-python
- `dev-js-workspace` → `/workspace` in dev-js
- `dev-all-workspace` → `/workspace` in dev-all

**Storage Class:** `ceph-block` (ReadWriteOnce)

All your code, configurations, and installed packages persist across pod restarts.

## Resource Limits

Each pod has:
- **Requests:** 8Gi RAM, 4 CPU cores
- **Limits:** 32Gi RAM, 16 CPU cores

These generous limits ensure smooth development experience for building large projects like SLIM.

Adjust in the pod YAML files if needed for different workloads.

## Management Scripts

### deploy.sh
Deploy all pods and PVCs to the cluster.

### status.sh
Show status of all development pods, PVCs, and resource usage.

### shell-*.sh
Connect to a specific development pod (rust, go, python, js).

### copy-to-pod.sh
Copy local files or directories to a development pod.

```bash
./scripts/copy-to-pod.sh dev-rust /path/to/myproject /workspace/myproject
```

### copy-from-pod.sh
Copy files or directories from a development pod to local machine.

```bash
./scripts/copy-from-pod.sh dev-rust /workspace/myproject ./myproject
```

### sync-to-pod.sh
Efficiently sync entire local directory to a pod using tar.

```bash
./scripts/sync-to-pod.sh dev-go ~/projects/myapp /workspace/myapp
```

### cleanup.sh
Delete all pods. Optionally delete PVCs (WARNING: deletes workspace data).

## Troubleshooting

### Permission Denied Errors

If you get "Unauthorized" or permission errors:

1. **Verify RBAC is applied**:
   ```bash
   kubectl get role dev-pods-manager -n lumuscar-jobs
   kubectl get clusterrole namespace-reader
   ```

2. **Check your context**:
   ```bash
   kubectl config current-context  # Should be gls-namespace
   kubectl auth can-i create pods -n lumuscar-jobs
   ```

3. **Verify service account token** (if using namespace-user):
   ```bash
   kubectl config view | grep -A 3 "name: namespace-user"
   ```

See [rbac/README.md](rbac/README.md) for detailed troubleshooting.

### Pod Initialization Issues

**Pod stuck in ContainerCreating**:
```bash
kubectl describe pod -n lumuscar-jobs <pod-name>
kubectl get events -n lumuscar-jobs --sort-by='.lastTimestamp'
```

**Check initialization progress**:
```bash
kubectl logs -f -n lumuscar-jobs <pod-name>
```

**Go installation fails in dev-all**: Use buildpack-deps base image (already configured) which includes wget/curl with proper proxy support.

**Git ownership errors** when building:
```bash
kubectl exec -n lumuscar-jobs <pod-name> -- git config --global --add safe.directory /workspace/<project>
```

### Proxy Issues

If downloads fail, verify proxy configuration:
```bash
kubectl exec -n lumuscar-jobs <pod-name> -- env | grep -i proxy
kubectl exec -n lumuscar-jobs <pod-name> -- curl -I https://www.google.com
```

## Customization

### Add Additional Tools

Edit the pod YAML files in `pods/` directory. The initialization script runs on pod startup:

```yaml
command:
  - /bin/bash
  - -c
  - |
    # Add your custom initialization here
    apt-get install -y additional-package
    pip install custom-package
    # etc...
```

### Change Resource Limits

Edit the `resources` section in pod YAML files:

```yaml
resources:
  requests:
    memory: "4Gi"  # Increase if needed
    cpu: "2000m"
  limits:
    memory: "16Gi"
    cpu: "8000m"
```

### Change Storage Size

Edit `pods/pvc.yaml` before initial deployment:

```yaml
resources:
  requests:
    storage: 100Gi  # Increase if needed
```

## Troubleshooting

### Pod Not Starting

Check logs:
```bash
kubectl logs -n lumuscar-jobs dev-rust
kubectl describe pod -n lumuscar-jobs dev-rust
```

### PVC Not Binding

Check PVC status:
```bash
kubectl get pvc -n lumuscar-jobs
kubectl describe pvc -n lumuscar-jobs dev-rust-workspace
```

Ensure `ceph-block` storage class exists:
```bash
kubectl get storageclass
```

### Network/Proxy Issues

Verify proxy configuration in pod:
```bash
kubectl exec -n lumuscar-jobs dev-rust -- env | grep -i proxy
```

Test connectivity:
```bash
kubectl exec -n lumuscar-jobs dev-rust -- curl -I https://github.com
```

### Initialization Taking Too Long

Pods take 5-10 minutes to fully initialize on first start as they:
- Install development tools (apt-get)
- Download language toolchains
- Install package managers and common libraries

Watch progress:
```bash
kubectl logs -f -n lumuscar-jobs dev-rust
```

## Architecture

```
k8s-dev/
├── pods/
│   ├── pvc.yaml           # PVC definitions (5x 50Gi)
│   ├── dev-rust.yaml      # Rust dev pod
│   ├── dev-go.yaml        # Go dev pod
│   ├── dev-python.yaml    # Python dev pod
│   ├── dev-js.yaml        # Node.js dev pod
│   └── dev-all.yaml       # All-in-one dev pod (buildpack-deps)
├── scripts/
│   ├── deploy.sh          # Deploy all resources
│   ├── status.sh          # Check pod status
│   ├── cleanup.sh         # Delete resources
│   ├── shell-rust.sh      # Shell into Rust pod
│   ├── shell-go.sh        # Shell into Go pod
│   ├── shell-python.sh    # Shell into Python pod
│   ├── shell-js.sh        # Shell into Node.js pod
│   ├── shell-all.sh       # Shell into all-in-one pod
│   ├── copy-to-pod.sh     # Copy local files to pod
│   ├── copy-from-pod.sh   # Copy files from pod to local
│   └── sync-to-pod.sh     # Sync directory to pod (efficient)
├── rbac/
│   ├── role.yaml                      # Namespace-scoped permissions
│   ├── rolebinding.yaml               # Bind role to service accounts
│   ├── clusterrole-reader.yaml        # Cluster-wide read permissions
│   ├── clusterrolebinding-reader.yaml # Bind cluster role
│   └── README.md                      # RBAC documentation
└── README.md              # This file
```

## License

Same as parent project.

## Contributing

PRs welcome! Please ensure:
- Scripts remain executable
- Documentation is updated
- Proxy configuration is preserved
- Resource limits are reasonable
