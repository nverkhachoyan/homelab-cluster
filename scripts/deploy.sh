#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl is required"
  exit 1
fi

if ! command -v helm >/dev/null 2>&1; then
  echo "helm is required for Traefik chart rendering"
  exit 1
fi

echo "[1/5] Applying media namespace"
kubectl apply -f "${REPO_ROOT}/kubernetes/workloads/namespace.yaml"

echo "[2/5] Applying platform stack (MetalLB, Traefik, Cloudflared)"
kubectl kustomize --enable-helm "${REPO_ROOT}/kubernetes/platform" | kubectl apply -f -

echo "[3/5] Waiting for platform deployments"
kubectl -n traefik rollout status deployment/traefik --timeout=300s
kubectl -n cloudflared rollout status deployment/cloudflared --timeout=300s

echo "[4/5] Applying storage + workloads"
kubectl apply -k "${REPO_ROOT}/kubernetes/workloads/storage"
kubectl apply -k "${REPO_ROOT}/kubernetes/workloads/apps"

echo "[5/5] Waiting for workload deployments"
for app in filebrowser flaresolverr jellyfin jellyseerr kavita prowlarr qbittorrent radarr readarr sonarr; do
  kubectl -n media rollout status "deployment/${app}" --timeout=300s
done

echo "Deploy complete."
