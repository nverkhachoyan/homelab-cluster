locals {
  utility_vms = {
    bootboy = {
      node_name     = "zeus"
      vm_id         = 108
      name          = "bootboy"
      bios          = "ovmf"
      machine       = "q35"
      scsi_hardware = "virtio-scsi-single"
      boot_order    = ["scsi0"]
      agent         = { enabled = true }
      cpu           = { cores = 2, sockets = 1, type = "x86-64-v2-AES" }
      memory        = { dedicated = 8192 }
      efi_disk      = { datastore_id = "local-lvm", type = "4m", pre_enrolled_keys = true }
      disks = [
        { interface = "scsi0", datastore_id = "local-lvm", size = 32, discard = "on", iothread = true, ssd = true },
        { interface = "scsi1", datastore_id = "local-lvm", size = 32, discard = "on", iothread = true },
      ]
      network_devices = [
        { bridge = "vmbr0", firewall = true, mac_address = "BC:24:11:C0:EB:9E", model = "virtio" },
      ]
      initialization = {
        datastore_id = "local-lvm"
        interface    = "ide2"
        ipv4         = { address = "dhcp" }
        ipv6         = { address = "dhcp" }
        user_account = { username = "nverk", keys = local.default_ssh_keys_with_comment }
      }
      operating_system = { type = "l26" }
    }

    llm_runner = {
      node_name     = "hera"
      vm_id         = 109
      name          = "llm-runner"
      bios          = "ovmf"
      machine       = "q35"
      scsi_hardware = "virtio-scsi-single"
      boot_order    = ["scsi0"]
      agent         = { enabled = true }
      cpu           = { cores = 4, sockets = 1, type = "x86-64-v2-AES" }
      memory        = { dedicated = 8192 }
      efi_disk      = { datastore_id = "local-lvm", type = "4m", pre_enrolled_keys = true }
      disks = [
        { interface = "scsi0", datastore_id = "local-lvm", size = 32, discard = "on", iothread = true, ssd = true },
      ]
      network_devices = [
        { bridge = "vmbr0", firewall = true, mac_address = "BC:24:11:28:D2:E4", model = "virtio" },
      ]
      initialization = {
        datastore_id = "local-lvm"
        interface    = "ide2"
        ipv4         = { address = "dhcp" }
        user_account = { username = "nverk", keys = local.default_ssh_keys_with_comment }
      }
      operating_system = { type = "l26" }
    }
  }
}
