locals {
  appliance_vms = {
    home_assistant = {
      node_name  = "apollo"
      vm_id      = 107
      name       = "home-assistant"
      tags       = ["homeassistant"]
      on_boot    = true
      started    = true
      bios       = "ovmf"
      machine    = "q35"
      boot_order = ["scsi0"]
      agent      = { enabled = true }
      cpu        = { cores = 4, sockets = 1, type = "host" }
      memory     = { dedicated = 8192 }
      efi_disk   = { pre_enrolled_keys = false }
      disks = [
        { interface = "scsi0", size = 64, discard = "on", iothread = true, ssd = true },
      ]
      network_devices = [
        { bridge = "vmbr0", firewall = true, mac_address = "BC:24:11:75:B6:4D", model = "virtio" },
        { bridge = proxmox_sdn_vnet.internal_lan.id, firewall = true, mac_address = "BC:24:11:CC:F3:0E", model = "virtio" },
      ]
      operating_system = { type = "l26" }
    }

    pfsense = {
      node_name  = "zeus"
      vm_id      = 110
      name       = "pfsense"
      tags       = ["gateway"]
      on_boot    = true
      started    = true
      bios       = "seabios"
      boot_order = ["ide0", "net0"]
      agent      = { enabled = true }
      cpu        = { cores = 2, sockets = 1, type = "host" }
      memory     = { dedicated = 8192 }
      disks = [
        { interface = "ide0", size = 16, discard = "on", iothread = false, ssd = true },
      ]
      network_devices = [
        { bridge = "vmbr0", firewall = true, mac_address = "BC:24:11:CB:25:50", model = "virtio" },
        { bridge = proxmox_sdn_vnet.internal_lan.id, firewall = true, mac_address = "BC:24:11:73:48:F4", model = "virtio", mtu = 1450 },
      ]
    }
  }
}
