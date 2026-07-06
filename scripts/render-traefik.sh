#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

TRAEFIK_CHART_REPO="${TRAEFIK_CHART_REPO:-https://traefik.github.io/charts}"
TRAEFIK_CHART_VERSION="${TRAEFIK_CHART_VERSION:-38.0.1}"

if ! command -v helm >/dev/null 2>&1; then
  echo "helm is required for Traefik chart rendering" >&2
  exit 1
fi

helm template traefik traefik \
  --repo "$TRAEFIK_CHART_REPO" \
  --version "$TRAEFIK_CHART_VERSION" \
  --namespace traefik \
  --values "${REPO_ROOT}/kubernetes/platform/traefik/values.yaml"
