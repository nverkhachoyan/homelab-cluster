locals {
  default_ssh_keys              = [regex("^\\S+\\s+\\S+", var.default_ssh_public_key)]
  default_ssh_keys_with_comment = [var.default_ssh_public_key]

  vms = merge(
    local.k3s_vms,
    local.utility_vms,
    local.appliance_vms,
    local.template_vms,
  )

  # Retained as an empty output to avoid state/output churn until manual guests
  # are intentionally tracked here.
  manual_initially = {}
}
