module "vms" {
  source   = "./modules/proxmox-vm"
  for_each = local.vms

  node_name        = each.value.node_name
  vm_id            = each.value.vm_id
  name             = each.value.name
  tags             = try(each.value.tags, [])
  template         = try(each.value.template, false)
  on_boot          = try(each.value.on_boot, false)
  bios             = try(each.value.bios, "seabios")
  machine          = try(each.value.machine, null)
  scsi_hardware    = try(each.value.scsi_hardware, null)
  boot_order       = try(each.value.boot_order, null)
  agent            = try(each.value.agent, null)
  cpu              = each.value.cpu
  memory           = each.value.memory
  efi_disk         = try(each.value.efi_disk, null)
  disks            = each.value.disks
  network_devices  = each.value.network_devices
  initialization   = try(each.value.initialization, null)
  operating_system = try(each.value.operating_system, null)
  serial_devices   = try(each.value.serial_devices, [])
  vga              = try(each.value.vga, null)
}
