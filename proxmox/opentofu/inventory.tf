locals {
  vms = merge(
    local.k3s_vms,
    local.utility_vms,
    local.appliance_vms,
    local.template_vms,
  )
}
