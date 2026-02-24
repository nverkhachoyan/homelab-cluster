#!/usr/bin/env bash
set -euo pipefail

# Generates scripts/secrets_cmd.sh.
# The generated script fetches the 1Password item "homelab-secrets"
# and applies the same Secret into both media and cloudflared namespaces.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
OUTPUT_SCRIPT="${REPO_ROOT}/scripts/secrets_cmd.sh"

if ! command -v op >/dev/null 2>&1; then
  echo "op is not installed or not in PATH"
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is not installed or not in PATH"
  exit 1
fi

cat > "$OUTPUT_SCRIPT" <<'GENEOF'
#!/usr/bin/env bash
set -euo pipefail

if ! command -v op >/dev/null 2>&1; then
  echo "op is not installed or not in PATH"
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is not installed or not in PATH"
  exit 1
fi

ITEM_JSON="$(op item get 'homelab-secrets' --format json)"
for NS in media cloudflared; do
  kubectl create namespace "$NS" --dry-run=client -o yaml | kubectl apply -f -

  echo "$ITEM_JSON" | jq --arg ns "$NS" '{
    apiVersion: "v1",
    kind: "Secret",
    metadata: {
      name: "homelab-secrets",
      namespace: $ns
    },
    type: "Opaque",
    stringData: (
      .fields
      | map(select(.value != null and .label != "notes") | {(.label): (.value | tostring)})
      | add
    )
  }' | kubectl apply -f -
done

echo "Secrets applied to media and cloudflared namespaces."
GENEOF

chmod +x "$OUTPUT_SCRIPT"
echo "Generated ${OUTPUT_SCRIPT}"
