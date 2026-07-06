output "vm_import_targets" {
  description = "VM import IDs for proxmox/scripts/import.sh."
  value = {
    for name, vm in local.vms : name => vm.import_id
  }
}

output "manual_initially" {
  description = "Existing guests intentionally left outside OpenTofu management for the first pass."
  value       = local.manual_initially
}
