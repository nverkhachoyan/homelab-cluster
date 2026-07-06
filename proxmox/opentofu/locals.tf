locals {
  default_ssh_keys = [var.default_ssh_public_key]

  vms = merge(
    local.k3s_vms,
    local.utility_vms,
    local.appliance_vms,
    local.template_vms,
  )

  manual_initially = {}
}
