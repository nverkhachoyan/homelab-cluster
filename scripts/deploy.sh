#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl is required" >&2
  exit 1
fi

if ! command -v helm >/dev/null 2>&1; then
  echo "helm is required for Traefik chart rendering" >&2
  exit 1
fi

echo "[1/6] Applying namespaces"
kubectl apply -f "${REPO_ROOT}/kubernetes/platform/namespaces.yaml"
kubectl apply -f "${REPO_ROOT}/kubernetes/workloads/namespace.yaml"

echo "[2/6] Applying MetalLB"
kubectl apply -k "${REPO_ROOT}/kubernetes/platform/metallb/install"
kubectl wait \
  --for=condition=Established \
  --timeout=120s \
  crd/ipaddresspools.metallb.io \
  crd/l2advertisements.metallb.io
kubectl -n metallb-system rollout status deployment/controller --timeout=300s
kubectl -n metallb-system rollout status daemonset/speaker --timeout=300s
kubectl apply -f "${REPO_ROOT}/kubernetes/platform/metallb/config.yaml"

echo "[3/6] Applying Traefik and Cloudflared"
"${SCRIPT_DIR}/render-traefik.sh" | kubectl apply -f -
kubectl apply -k "${REPO_ROOT}/kubernetes/platform/cloudflared"

echo "[4/6] Waiting for platform deployments"
kubectl -n traefik rollout status deployment/traefik --timeout=300s
kubectl -n cloudflared rollout status deployment/cloudflared --timeout=300s

echo "[5/6] Applying storage + workloads"
kubectl apply -k "${REPO_ROOT}/kubernetes/workloads"

echo "[6/6] Waiting for workload deployments"
for app in filebrowser flaresolverr jellyfin jellyseerr kavita prowlarr qbittorrent radarr readarr sonarr; do
  kubectl -n media rollout status "deployment/${app}" --timeout=300s
done

echo "Deploy complete."
