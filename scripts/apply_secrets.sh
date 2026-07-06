#!/usr/bin/env bash
set -euo pipefail

ITEM_NAME="${OP_ITEM_NAME:-homelab-secrets}"

if ! command -v op >/dev/null 2>&1; then
  echo "op is not installed or not in PATH" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is not installed or not in PATH" >&2
  exit 1
fi

if ! command -v kubectl >/dev/null 2>&1; then
  echo "kubectl is not installed or not in PATH" >&2
  exit 1
fi

ITEM_JSON="$(op item get "$ITEM_NAME" --format json)"

field_value() {
  local label="$1"
  jq -er --arg label "$label" '
    [
      .fields[]
      | select(.label == $label and .value != null)
      | .value
    ][0]
  ' <<< "$ITEM_JSON"
}

require_field() {
  local label="$1"

  if ! field_value "$label" >/dev/null; then
    echo "Missing required 1Password field: ${label}" >&2
    exit 1
  fi
}

secret_manifest() {
  local namespace="$1"
  local name="$2"
  local data="$3"

  jq -n \
    --arg namespace "$namespace" \
    --arg name "$name" \
    --argjson data "$data" \
    '{
      apiVersion: "v1",
      kind: "Secret",
      metadata: {
        name: $name,
        namespace: $namespace
      },
      type: "Opaque",
      stringData: $data
    }'
}

for field in \
  cloudflare_tunnel_token \
  protonvpn_wireguard_private_key \
  qbittorrent_webui_username \
  qbittorrent_webui_password; do
  require_field "$field"
done

kubectl create namespace cloudflared --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace media --dry-run=client -o yaml | kubectl apply -f -

secret_manifest cloudflared homelab-secrets "$(
  jq -n \
    --arg cloudflare_tunnel_token "$(field_value cloudflare_tunnel_token)" \
    '{cloudflare_tunnel_token: $cloudflare_tunnel_token}'
)" | kubectl apply -f -

secret_manifest media protonvpn-secrets "$(
  jq -n \
    --arg wireguard_private_key "$(field_value protonvpn_wireguard_private_key)" \
    '{wireguard_private_key: $wireguard_private_key}'
)" | kubectl apply -f -

secret_manifest media qbittorrent-webui-secrets "$(
  jq -n \
    --arg username "$(field_value qbittorrent_webui_username)" \
    --arg password "$(field_value qbittorrent_webui_password)" \
    '{username: $username, password: $password}'
)" | kubectl apply -f -

echo "Secrets applied."
