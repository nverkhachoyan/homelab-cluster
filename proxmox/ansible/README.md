# Proxmox Node Configuration (Ansible)

OpenTofu in `proxmox/` manages what the Proxmox API exposes: VMs, SDN and
storage. This directory manages the node operating systems underneath, which
the API can't reach: files under `/etc`, kernel command line options, host
services.

Settings here survive reboots and package upgrades on their own. Re-run the
playbook after reinstalling a node or adding a new one, or to check for drift.

## Requirements

Run from a machine on the home LAN with root SSH access to the nodes. Ansible
doesn't need to be installed; `uvx` runs it on demand:

```sh
cd proxmox/ansible
uvx --from ansible-core ansible-playbook site.yml --check --diff   # preview
uvx --from ansible-core ansible-playbook site.yml                  # apply
uvx --from ansible-core ansible-playbook site.yml --limit athena   # one node
```

The inventory uses IPs because node hostnames don't resolve on the LAN.

## Roles

### `headless_display`

Keeps a display output driven with no monitor attached, so Intel AMT KVM
(remote screen) has an active display pipe to capture. Without it the i915
driver turns every output off on a headless node and AMT shows a black screen.

- Persistent: writes `/etc/default/grub.d/headless-display.cfg`, which appends
  `video=DP-1:1920x1080@60e` to the kernel command line, then runs
  `update-grub`. The trailing `e` forces the output on.
- Live: marks the connector as connected through sysfs, so no reboot is needed.

This only covers Linux. Firmware screens (HP logo, F10 setup, GRUB) need a
DisplayPort EDID dummy plug. If a plug ends up on a port other than DP-1, set
`headless_display_connector` for that host in `inventory.yml`.

## Adding a Role

Create `roles/<name>/` with `tasks/main.yml` (plus `defaults/`, `templates/`,
`handlers/` as needed) and list it in `site.yml`. Keep secrets out of the repo;
read them from environment variables loaded by direnv, as the other tooling
here does.
