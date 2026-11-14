locals {
  vms = merge(
    local.k3s_vms,
    local.appliance_vms,
    local.general_vms,
  )
}
