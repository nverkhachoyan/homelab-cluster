#!/usr/bin/env bash
set -euo pipefail

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl is not installed or not in PATH" >&2
  exit 1
fi

require_env() {
  local env_name="$1"

  if [[ -z "${!env_name:-}" ]]; then
    echo "Missing required environment variable: ${env_name}" >&2
    exit 1
  fi
}

apply_secret() {
  local namespace="$1"
  local name="$2"
  shift 2

  kubectl -n "$namespace" create secret generic "$name" "$@" \
    --dry-run=client \
    -o yaml \
    | kubectl apply -f -
}

require_env CLOUDFLARE_TUNNEL_TOKEN
require_env PROTONVPN_WIREGUARD_PRIVATE_KEY
require_env QBITTORRENT_WEBUI_USERNAME
require_env QBITTORRENT_WEBUI_PASSWORD

kubectl create namespace cloudflared --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace media --dry-run=client -o yaml | kubectl apply -f -

apply_secret cloudflared homelab-secrets \
  --from-file=cloudflare_tunnel_token=<(printf '%s' "$CLOUDFLARE_TUNNEL_TOKEN")

apply_secret media protonvpn-secrets \
  --from-file=wireguard_private_key=<(printf '%s' "$PROTONVPN_WIREGUARD_PRIVATE_KEY")

apply_secret media qbittorrent-webui-secrets \
  --from-file=username=<(printf '%s' "$QBITTORRENT_WEBUI_USERNAME") \
  --from-file=password=<(printf '%s' "$QBITTORRENT_WEBUI_PASSWORD")

echo "Secrets applied."
