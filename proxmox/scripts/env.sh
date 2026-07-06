#!/usr/bin/env bash

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  echo "source this script from another Proxmox helper; do not execute it directly" >&2
  exit 1
fi

proxmox_restore_xtrace=false
if [[ $- == *x* ]]; then
  proxmox_restore_xtrace=true
  set +x
fi

restore_xtrace() {
  if [[ "$proxmox_restore_xtrace" == "true" ]]; then
    set -x
  fi
}

export PROXMOX_VE_ENDPOINT="${PROXMOX_VE_ENDPOINT:-https://zeus.alligator-rainbow.ts.net:8006/}"
export PROXMOX_VE_INSECURE="${PROXMOX_VE_INSECURE:-true}"
export PROXMOX_VE_SSH_USERNAME="${PROXMOX_VE_SSH_USERNAME:-root}"
export PROXMOX_VE_SSH_AGENT="${PROXMOX_VE_SSH_AGENT:-true}"
export AWS_EC2_METADATA_DISABLED="${AWS_EC2_METADATA_DISABLED:-true}"

export TF_VAR_proxmox_endpoint="${TF_VAR_proxmox_endpoint:-$PROXMOX_VE_ENDPOINT}"
export TF_VAR_proxmox_insecure="${TF_VAR_proxmox_insecure:-$PROXMOX_VE_INSECURE}"
export TF_VAR_proxmox_ssh_username="${TF_VAR_proxmox_ssh_username:-$PROXMOX_VE_SSH_USERNAME}"
export TF_VAR_proxmox_ssh_agent="${TF_VAR_proxmox_ssh_agent:-$PROXMOX_VE_SSH_AGENT}"

proxmox_token_ready=false
aws_backend_ready=false
item_json=""

field_exists() {
  local label="$1"
  jq -e --arg label "$label" '
    any(.fields[]; .label == $label and .value != null and .value != "")
  ' <<< "$item_json" >/dev/null
}

field_value() {
  local label="$1"
  jq -er --arg label "$label" '
    [
      .fields[]
      | select(.label == $label and .value != null)
      | .value
    ][0]
  ' <<< "$item_json"
}

if [[ -n "${PROXMOX_VE_API_TOKEN:-}" ]]; then
  proxmox_token_ready=true
elif [[ -n "${PROXMOX_VE_API_TOKEN_ID:-}" && -n "${PROXMOX_VE_API_TOKEN_SECRET:-}" ]]; then
  export PROXMOX_VE_API_TOKEN="${PROXMOX_VE_API_TOKEN_ID}=${PROXMOX_VE_API_TOKEN_SECRET}"
  proxmox_token_ready=true
fi

if [[ -n "${AWS_ACCESS_KEY_ID:-}" && -n "${AWS_SECRET_ACCESS_KEY:-}" ]]; then
  aws_backend_ready=true
elif [[ -n "${AWS_PROFILE:-}" ]]; then
  aws_backend_ready=true
elif [[ -n "${OPENTOFU_STATE_AWS_ACCESS_KEY_ID:-}" && -n "${OPENTOFU_STATE_AWS_SECRET_ACCESS_KEY:-}" ]]; then
  export AWS_ACCESS_KEY_ID="$OPENTOFU_STATE_AWS_ACCESS_KEY_ID"
  export AWS_SECRET_ACCESS_KEY="$OPENTOFU_STATE_AWS_SECRET_ACCESS_KEY"
  aws_backend_ready=true
fi

if [[ "$proxmox_token_ready" != "true" || "$aws_backend_ready" != "true" ]]; then
  if command -v op >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
    item_name="${OP_ITEM_NAME:-homelab-secrets}"
    item_json="$(op item get "$item_name" --format json)"
  fi
fi

if [[ "$proxmox_token_ready" != "true" && -n "$item_json" ]]; then
  if field_exists proxmox_api_token_id && field_exists proxmox_api_token_secret; then
    token_id="$(field_value proxmox_api_token_id)"
    token_secret="$(field_value proxmox_api_token_secret)"
    export PROXMOX_VE_API_TOKEN="${token_id}=${token_secret}"
    proxmox_token_ready=true
  fi
fi

if [[ "$aws_backend_ready" != "true" && -n "$item_json" ]]; then
  if field_exists aws_s3_backend_access_key_id && field_exists aws_s3_backend_secret_access_key; then
    access_key_id="$(field_value aws_s3_backend_access_key_id)"
    secret_access_key="$(field_value aws_s3_backend_secret_access_key)"
    export AWS_ACCESS_KEY_ID="$access_key_id"
    export AWS_SECRET_ACCESS_KEY="$secret_access_key"
    aws_backend_ready=true
  fi
fi

export AWS_REGION="${AWS_REGION:-us-west-1}"
export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-us-west-1}"

if [[ "$proxmox_token_ready" != "true" ]]; then
  echo "Missing Proxmox credentials. Set PROXMOX_VE_API_TOKEN, or add proxmox_api_token_id/proxmox_api_token_secret to 1Password item homelab-secrets." >&2
  restore_xtrace
  unset proxmox_restore_xtrace
  unset -f restore_xtrace field_exists field_value
  return 1
fi

if [[ "$aws_backend_ready" != "true" ]]; then
  echo "Missing AWS S3 backend credentials. Set AWS_ACCESS_KEY_ID/AWS_SECRET_ACCESS_KEY, AWS_PROFILE, or add aws_s3_backend_access_key_id/aws_s3_backend_secret_access_key to 1Password item homelab-secrets." >&2
  restore_xtrace
  unset proxmox_restore_xtrace
  unset -f restore_xtrace field_exists field_value
  return 1
fi

restore_xtrace
unset proxmox_token_ready aws_backend_ready item_json access_key_id secret_access_key
unset proxmox_restore_xtrace
unset -f restore_xtrace field_exists field_value
