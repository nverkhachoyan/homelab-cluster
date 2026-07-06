locals {
  ci_runner_vms = {
    actions_runner = {
      import_id     = "poseidon/111"
      node_name     = "poseidon"
      vm_id         = 111
      name          = "actions-runner"
      tags          = ["ci"]
      on_boot       = true
      bios          = "ovmf"
      machine       = "q35"
      scsi_hardware = "virtio-scsi-single"
      boot_order    = ["scsi0"]
      agent         = { enabled = true }
      cpu           = { cores = 4, sockets = 1, type = "host" }
      memory        = { dedicated = 8192 }
      efi_disk      = { datastore_id = "local-lvm", type = "4m", pre_enrolled_keys = true }
      disks = [
        { interface = "scsi0", datastore_id = "local-lvm", size = 32, discard = "on", iothread = true, ssd = true },
      ]
      network_devices = [
        { bridge = "vmbr0", firewall = true, mac_address = "BC:24:11:3C:8D:58", model = "virtio" },
      ]
      initialization = {
        datastore_id = "local-lvm"
        interface    = "ide2"
        ipv4         = { address = "dhcp" }
        ipv6         = { address = "dhcp" }
        user_account = { username = "casadmin", keys = local.default_ssh_keys }
      }
      operating_system = { type = "l26" }
    }

    actions_runner_1 = {
      import_id     = "zeus/112"
      node_name     = "zeus"
      vm_id         = 112
      name          = "actions-runner-1"
      tags          = ["ci"]
      bios          = "ovmf"
      machine       = "q35"
      scsi_hardware = "virtio-scsi-single"
      boot_order    = ["scsi0"]
      agent         = { enabled = true }
      cpu           = { cores = 2, sockets = 1, type = "host" }
      memory        = { dedicated = 16384 }
      efi_disk      = { datastore_id = "local-lvm", type = "4m", pre_enrolled_keys = true }
      disks = [
        { interface = "scsi0", datastore_id = "local-lvm", size = 64, discard = "on", iothread = true, ssd = true },
      ]
      network_devices = [
        { bridge = "vmbr0", firewall = true, mac_address = "BC:24:11:9D:F6:6D", model = "virtio" },
      ]
      initialization = {
        datastore_id = "local-lvm"
        interface    = "ide2"
        ipv4         = { address = "dhcp" }
        ipv6         = { address = "dhcp" }
        user_account = { username = "casadmin", keys = local.default_ssh_keys }
      }
      operating_system = { type = "l26" }
    }

    actions_runner_2 = {
      import_id     = "hera/114"
      node_name     = "hera"
      vm_id         = 114
      name          = "actions-runner-2"
      tags          = ["ci"]
      on_boot       = true
      bios          = "ovmf"
      machine       = "q35"
      scsi_hardware = "virtio-scsi-single"
      boot_order    = ["scsi0"]
      agent         = { enabled = true }
      cpu           = { cores = 4, sockets = 1, type = "host" }
      memory        = { dedicated = 8192 }
      efi_disk      = { datastore_id = "local-lvm", type = "4m", pre_enrolled_keys = true }
      disks = [
        { interface = "scsi0", datastore_id = "local-lvm", size = 32, discard = "on", iothread = true, ssd = true },
      ]
      network_devices = [
        { bridge = "vmbr0", firewall = true, mac_address = "BC:24:11:CB:C4:6D", model = "virtio" },
      ]
      initialization = {
        datastore_id = "local-lvm"
        interface    = "ide2"
        ipv4         = { address = "dhcp" }
        ipv6         = { address = "dhcp" }
        user_account = { username = "casadmin", keys = local.default_ssh_keys }
      }
      operating_system = { type = "l26" }
    }
  }
}
