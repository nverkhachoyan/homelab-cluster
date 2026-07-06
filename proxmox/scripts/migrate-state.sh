#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
TOFU_BIN="${TOFU_BIN:-tofu}"
TOFU_DIR="${REPO_ROOT}/proxmox/opentofu"

if ! command -v "$TOFU_BIN" >/dev/null 2>&1; then
  echo "OpenTofu is required. Run this from nix develop, or set TOFU_BIN." >&2
  exit 1
fi

# shellcheck source=proxmox/scripts/env.sh
source "${SCRIPT_DIR}/env.sh"

if [[ -f "${TOFU_DIR}/terraform.tfstate" ]]; then
  timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
  cp -p "${TOFU_DIR}/terraform.tfstate" "${TOFU_DIR}/terraform.tfstate.pre-s3-migration.${timestamp}.backup"
  unset timestamp
fi

"$TOFU_BIN" -chdir="$TOFU_DIR" init -migrate-state -force-copy -input=false
