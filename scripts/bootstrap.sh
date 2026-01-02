#!/usr/bin/env bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

if ! command -v kubectl &> /dev/null; then
    log_error "kubectl is not installed or not in PATH"
    exit 1
fi


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

log_info "Step 1: Installing ArgoCD..."
kubectl apply -k "${REPO_ROOT}/kubernetes/platform/argocd"
log_info "ArgoCD installed successfully"

log_info "Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd 2>/dev/null || {
    log_warn "ArgoCD server not ready yet, waiting longer..."
    sleep 30
}

log_info "Step 2: Applying root Application..."
kubectl apply -f "${REPO_ROOT}/kubernetes/bootstrap/root.yaml"

log_info "Bootstrap complete!"
