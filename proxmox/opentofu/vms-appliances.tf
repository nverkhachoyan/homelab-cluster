locals {
  appliance_vms = {
    win11 = {
      node_name     = "zeus"
      vm_id         = 102
      name          = "win11"
      bios          = "ovmf"
      machine       = "pc-q35-10.1"
      scsi_hardware = "virtio-scsi-single"
      boot_order    = ["scsi0", "ide2", "ide0", "net0"]
      agent         = { enabled = true }
      cpu           = { cores = 4, sockets = 1, type = "x86-64-v2-AES" }
      memory        = { dedicated = 8192 }
      efi_disk      = { datastore_id = "local-lvm", type = "4m", pre_enrolled_keys = true }
      disks = [
        { interface = "scsi0", datastore_id = "local-lvm", size = 100, discard = "on", iothread = true },
      ]
      network_devices = [
        { bridge = "vmbr0", firewall = false, mac_address = "BC:24:11:4D:15:2B", model = "virtio" },
      ]
      operating_system = { type = "win11" }
    }

    home_assistant = {
      node_name     = "apollo"
      vm_id         = 107
      name          = "home-assistant"
      tags          = ["homeassistant"]
      on_boot       = true
      started       = true
      bios          = "ovmf"
      machine       = "q35"
      scsi_hardware = "virtio-scsi-single"
      boot_order    = ["scsi0"]
      agent         = { enabled = true }
      cpu           = { cores = 4, sockets = 1, type = "host" }
      memory        = { dedicated = 8192 }
      efi_disk      = { datastore_id = "local-lvm", type = "4m", pre_enrolled_keys = false }
      disks = [
        { interface = "scsi0", datastore_id = "local-lvm", size = 64, discard = "on", iothread = true, ssd = true },
      ]
      network_devices = [
        { bridge = "vmbr0", firewall = true, mac_address = "BC:24:11:75:B6:4D", model = "virtio" },
        { bridge = "vxvnet1", firewall = true, mac_address = "BC:24:11:CC:F3:0E", model = "virtio" },
      ]
      operating_system = { type = "l26" }
    }

    pfsense = {
      node_name     = "zeus"
      vm_id         = 110
      name          = "pfsense"
      tags          = ["gateway"]
      on_boot       = true
      started       = true
      bios          = "seabios"
      scsi_hardware = "virtio-scsi-single"
      boot_order    = ["ide0", "net0"]
      agent         = { enabled = true }
      cpu           = { cores = 2, sockets = 1, type = "host" }
      memory        = { dedicated = 8192 }
      disks = [
        { interface = "ide0", datastore_id = "local-lvm", size = 16, discard = "on", iothread = false, ssd = true },
      ]
      network_devices = [
        { bridge = "vmbr0", firewall = true, mac_address = "BC:24:11:CB:25:50", model = "virtio" },
        { bridge = "vxvnet1", firewall = true, mac_address = "BC:24:11:73:48:F4", model = "virtio", mtu = 1450 },
      ]
    }
  }
}
