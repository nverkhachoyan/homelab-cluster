#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"
TOFU_BIN="${TOFU_BIN:-tofu}"
TOFU_DIR="${REPO_ROOT}/proxmox/opentofu"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

if ! command -v "$TOFU_BIN" >/dev/null 2>&1; then
  echo "OpenTofu is required. Run this from nix develop, or set TOFU_BIN." >&2
  exit 1
fi

"$TOFU_BIN" -chdir="$TOFU_DIR" fmt -check -recursive
TF_DATA_DIR="$TMP_DIR" "$TOFU_BIN" -chdir="$TOFU_DIR" init -backend=false -input=false
TF_DATA_DIR="$TMP_DIR" "$TOFU_BIN" -chdir="$TOFU_DIR" validate
