locals {
  default_ssh_keys = [var.default_ssh_public_key]

  vms = merge(
    local.k3s_vms,
    local.utility_vms,
    local.ci_runner_vms,
    local.template_vms,
  )

  manual_initially = {
    pfsense        = { id = "zeus/110", reason = "gateway appliance; avoid API-driven edits until network rollback path exists" }
    home_assistant = { id = "apollo/107", reason = "appliance state lives inside guest; import later for inventory/drift only" }
    win11          = { id = "zeus/102", reason = "installer ISO, TPM, and guest state are better kept manual initially" }
  }
}
