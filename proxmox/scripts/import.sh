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

"$TOFU_BIN" -chdir="$TOFU_DIR" init -input=false
state_addresses="$("$TOFU_BIN" -chdir="$TOFU_DIR" state list 2>/dev/null || true)"

already_imported() {
  local address="$1"

  grep -Fxq "$address" <<< "$state_addresses"
}

while IFS='|' read -r address import_id; do
  [[ -z "$address" || "$address" == \#* ]] && continue

  if already_imported "$address"; then
    echo "Already imported: $address"
    continue
  fi

  echo "Importing $address from $import_id"
  "$TOFU_BIN" -chdir="$TOFU_DIR" import "$address" "$import_id"
done <<'IMPORTS'
# SDN resources
proxmox_sdn_zone_vxlan.myzone|myzone
proxmox_sdn_vnet.vxvnet1|vxvnet1
proxmox_sdn_subnet.myzone_10_0_0_0_24|vxvnet1/myzone-10.0.0.0-24

# k3s VMs
module.vms["k3s_server_01"].proxmox_virtual_environment_vm.this|zeus/100
module.vms["k3s_server_02"].proxmox_virtual_environment_vm.this|poseidon/101
module.vms["k3s_agent_02"].proxmox_virtual_environment_vm.this|hera/106

# Utility VMs
module.vms["bootboy"].proxmox_virtual_environment_vm.this|zeus/108
module.vms["llm_runner"].proxmox_virtual_environment_vm.this|hera/109

# CI runner VMs
module.vms["actions_runner"].proxmox_virtual_environment_vm.this|poseidon/111
module.vms["actions_runner_1"].proxmox_virtual_environment_vm.this|zeus/112
module.vms["actions_runner_2"].proxmox_virtual_environment_vm.this|hera/114

# Templates
module.vms["ubuntu_cloudinit_template"].proxmox_virtual_environment_vm.this|zeus/1000
module.vms["actions_runner_template"].proxmox_virtual_environment_vm.this|hera/113
module.vms["ubuntu_runner_template"].proxmox_virtual_environment_vm.this|athena/9000
IMPORTS
