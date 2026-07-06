#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl is required" >&2
  exit 1
fi

echo "[1/3] Rendering platform manifests"
kubectl kustomize "${REPO_ROOT}/kubernetes/platform" > "${TMP_DIR}/platform.yaml"

echo "[2/3] Rendering Traefik chart"
"${SCRIPT_DIR}/render-traefik.sh" > "${TMP_DIR}/traefik.yaml"

echo "[3/3] Rendering workload manifests"
kubectl kustomize "${REPO_ROOT}/kubernetes/workloads" > "${TMP_DIR}/workloads.yaml"

if command -v kubeconform >/dev/null 2>&1; then
  kubeconform -strict -ignore-missing-schemas -summary "${TMP_DIR}"/*.yaml
else
  echo "kubeconform not found; render validation only."
fi

echo "Validation complete."
