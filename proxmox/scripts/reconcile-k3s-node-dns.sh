#!/usr/bin/env bash
set -euo pipefail

PROXMOX_SSH_TARGET="${PROXMOX_SSH_TARGET:-root@zeus.alligator-rainbow.ts.net}"
K3S_VM_ID="${K3S_VM_ID:-100}"
GUEST_DNS_LINK="${GUEST_DNS_LINK:-eth0}"
GUEST_DNS_SERVERS="${GUEST_DNS_SERVERS:-1.1.1.1 1.0.0.1}"
GUEST_DNS_DOMAIN="${GUEST_DNS_DOMAIN:-alligator-rainbow.ts.net}"

guest_script='
set -euo pipefail

systemctl enable --now ssh

if command -v tailscale >/dev/null 2>&1; then
  tailscale set --accept-dns=false
fi

resolvectl dns "$GUEST_DNS_LINK" $GUEST_DNS_SERVERS
resolvectl domain "$GUEST_DNS_LINK" "$GUEST_DNS_DOMAIN"

systemctl is-active --quiet ssh
getent hosts region1.v2.argotunnel.com cloudflare.com >/dev/null
'

remote_cmd=$(
  printf 'qm guest exec %q -- env GUEST_DNS_LINK=%q GUEST_DNS_SERVERS=%q GUEST_DNS_DOMAIN=%q bash -lc %q' \
    "$K3S_VM_ID" \
    "$GUEST_DNS_LINK" \
    "$GUEST_DNS_SERVERS" \
    "$GUEST_DNS_DOMAIN" \
    "$guest_script"
)

json="$(ssh -o BatchMode=yes "$PROXMOX_SSH_TARGET" "$remote_cmd")"

printf '%s\n' "$json" | python3 -c '
import json
import sys

data = json.load(sys.stdin)
for key in ("out-data", "err-data"):
    value = data.get(key)
    if value:
        print(value, end="" if value.endswith("\n") else "\n")

exit_code = data.get("exitcode", 1)
if exit_code:
    print(f"guest command failed with exit code {exit_code}", file=sys.stderr)
sys.exit(exit_code)
'
