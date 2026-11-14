locals {
  general_vms = {
    akademos = {
      node_name  = "hera"
      vm_id      = 101
      name       = "akademos"
      on_boot    = true
      started    = true
      bios       = "ovmf"
      machine    = "q35"
      boot_order = ["scsi0", "ide2", "net0"]
      agent      = { enabled = true }
      cpu        = { cores = 2, sockets = 1, type = "x86-64-v2-AES" }
      memory     = { dedicated = 4096 }
      efi_disk   = { pre_enrolled_keys = true }
      disks = [
        { interface = "scsi0", size = 32, discard = "on", iothread = true },
      ]
      network_devices = [
        { bridge = "vmbr0", firewall = true, mac_address = "BC:24:11:16:EA:17", model = "virtio" },
      ]
      operating_system = { type = "l26" }
    }
  }
}
