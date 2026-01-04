#!/usr/bin/env bash
set -euo pipefail

# This script generates the secrets_cmd.sh file from the 1Password item "homelab-secrets"
# Ready CMD to copy and paste into the cluster

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

# Check if op is installed
if ! command -v op &> /dev/null; then
    echo "op is not installed or not in PATH"
    exit 1
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "jq is not installed or not in PATH"
    exit 1
fi

# Generate the secrets
op item get "homelab-secrets" --format json | \
jq -r '[.fields[] | select(.value != null and .label != "notes") | "--from-literal=\(.label)=\(.value)"] | "kubectl create secret generic homelab-secrets \(. | join(" ")) -n default"' > "${REPO_ROOT}/scripts/secrets_cmd.sh"
