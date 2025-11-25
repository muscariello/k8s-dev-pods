# Kubernetes Development Pods

Permanent development pods for Rust, Go, Python, and Node.js in the `lumuscar-jobs` namespace.

## Overview

This repository contains Kubernetes configurations for five persistent development environments:

- **dev-rust**: Rust development with full toolchain
- **dev-go**: Go development with common tools
- **dev-python**: Python development with pyenv and common packages
- **dev-js**: Node.js development with npm/yarn/pnpm
- **dev-all**: All-in-one environment with Rust, Go, Python, and Node.js

Each pod has:
- 50Gi persistent workspace storage
- HTTP proxy configuration for Cisco network
- Full development toolchain for the respective language(s)
- Resource limits (8Gi request/32Gi limit RAM, 4/16 CPU cores)

## Quick Start

### Deploy All Pods

```bash
# Deploy with default proxy configuration
./scripts/deploy.sh

# Or specify custom proxy
HTTP_PROXY=http://your-proxy:port ./scripts/deploy.sh
```

This will:
1. Create 4 PVCs (50Gi each) for workspace persistence
2. Deploy all 4 development pods
3. Initialize each environment (takes 5-10 minutes first time)

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
```

Or manually:

```bash
kubectl exec -it -n lumuscar-jobs dev-rust -- /bin/bash
```

### Copy Code to Pods

**Copy a single file or directory:**
```bash
./scripts/copy-to-pod.sh dev-rust /Users/me/myproject /workspace/myproject
./scripts/copy-to-pod.sh dev-go ./mycode /workspace/mycode
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

### dev-rust (Rust 1.90)

**Installed Tools:**
- Rust 1.90 with clippy, rustfmt, rust-analyzer
- LLVM 19 full suite (clang, lld, lldb)
- Cross-compilation targets: x86_64, aarch64
- Cargo tools: cargo-watch, cargo-edit, cargo-outdated, cargo-audit
- Build tools: gcc, g++, make, cmake, pkg-config
- Libraries: libssl-dev, libicu-dev, libxml2-dev, libz3-dev
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

### dev-go (Go 1.23)

**Installed Tools:**
- Go 1.23
- gopls (language server)
- delve (debugger)
- staticcheck, goimports, golangci-lint
- Task (build automation)
- Build tools: gcc, g++, make, protobuf-compiler
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

**Installed Tools:**
- Python 3.13
- pyenv (for multiple Python versions)
- Testing: pytest, pytest-cov
- Linting: black, flake8, mypy, pylint
- Tools: ipython, jupyter, jupyterlab
- Libraries: requests, httpx, aiohttp, pandas, numpy, matplotlib
- Package managers: poetry, pipenv, pip
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

### dev-js (Node.js 22)

**Installed Tools:**
- Node.js 22 (latest)
- NVM for version management
- TypeScript, ts-node, @types/node
- Linting: eslint, prettier
- Package managers: npm, yarn, pnpm
- Build tools: webpack, vite
- Process managers: nodemon, pm2
- Monorepo: nx
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

## Network Configuration

All pods are configured with HTTP proxy for Cisco network:

```yaml
env:
  - name: HTTP_PROXY
    value: "http://proxy-wsa.esl.cisco.com:80"
  - name: HTTPS_PROXY
    value: "http://proxy-wsa.esl.cisco.com:80"
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

**Storage Class:** `ceph-block` (ReadWriteOnce)

All your code, configurations, and installed packages persist across pod restarts.

## Resource Limits

Each pod has:
- **Requests:** 2Gi RAM, 1 CPU core
- **Limits:** 8Gi RAM, 4 CPU cores

Adjust in the pod YAML files if needed.

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
│   ├── pvc.yaml           # PVC definitions (4x 50Gi)
│   ├── dev-rust.yaml      # Rust dev pod
│   ├── dev-go.yaml        # Go dev pod
│   ├── dev-python.yaml    # Python dev pod
│   └── dev-js.yaml        # Node.js dev pod
├── scripts/
│   ├── deploy.sh          # Deploy all resources
│   ├── status.sh          # Check pod status
│   ├── cleanup.sh         # Delete resources
│   ├── shell-rust.sh      # Shell into Rust pod
│   ├── shell-go.sh        # Shell into Go pod
│   ├── shell-python.sh    # Shell into Python pod
│   ├── shell-js.sh        # Shell into Node.js pod
│   ├── copy-to-pod.sh     # Copy local files to pod
│   ├── copy-from-pod.sh   # Copy files from pod to local
│   └── sync-to-pod.sh     # Sync directory to pod (efficient)
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
