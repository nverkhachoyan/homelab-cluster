module "vms" {
  source   = "./modules/proxmox-vm"
  for_each = local.vms

  vm = each.value
}
