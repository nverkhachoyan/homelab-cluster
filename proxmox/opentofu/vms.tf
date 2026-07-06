module "vms" {
  source   = "./modules/proxmox-vm"
  for_each = local.vms

  node_name        = each.value.node_name
  vm_id            = each.value.vm_id
  name             = each.value.name
  tags             = try(each.value.tags, [])
  template         = try(each.value.template, false)
  on_boot          = try(each.value.on_boot, false)
  started          = try(each.value.started, null)
  stop_on_destroy  = try(each.value.stop_on_destroy, null)
  protection       = try(each.value.protection, null)
  purge_on_destroy = try(each.value.purge_on_destroy, null)
  delete_unreferenced_disks_on_destroy = try(
    each.value.delete_unreferenced_disks_on_destroy,
    null,
  )
  bios             = try(each.value.bios, "seabios")
  machine          = try(each.value.machine, null)
  scsi_hardware    = try(each.value.scsi_hardware, null)
  boot_order       = try(each.value.boot_order, null)
  startup          = try(each.value.startup, null)
  agent            = try(each.value.agent, null)
  cpu              = each.value.cpu
  memory           = each.value.memory
  efi_disk         = try(each.value.efi_disk, null)
  tpm_state        = try(each.value.tpm_state, null)
  disks            = each.value.disks
  cdrom            = try(each.value.cdrom, null)
  network_devices  = each.value.network_devices
  initialization   = try(each.value.initialization, null)
  operating_system = try(each.value.operating_system, null)
  serial_devices   = try(each.value.serial_devices, [])
  vga              = try(each.value.vga, null)
}
