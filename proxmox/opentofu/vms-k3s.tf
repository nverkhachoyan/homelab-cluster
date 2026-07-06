locals {
  k3s_vms = {
    k3s_server_01 = {
      import_id     = "zeus/100"
      node_name     = "zeus"
      vm_id         = 100
      name          = "k3s-server-01"
      tags          = ["k3s-server"]
      on_boot       = true
      bios          = "ovmf"
      machine       = "q35"
      scsi_hardware = "virtio-scsi-single"
      boot_order    = ["scsi0"]
      agent         = { enabled = true }
      cpu           = { cores = 4, sockets = 1, type = "x86-64-v2-AES" }
      memory        = { dedicated = 16384 }
      efi_disk      = { datastore_id = "local-lvm", type = "4m", pre_enrolled_keys = true }
      disks = [
        { interface = "scsi0", datastore_id = "local-lvm", size = 32, discard = "on", iothread = true, ssd = true },
        { interface = "scsi1", datastore_id = "local-lvm", size = 100, discard = "on", iothread = true, ssd = true },
      ]
      network_devices = [
        { bridge = "vxvnet1", mac_address = "BC:24:11:BD:43:33", model = "virtio", mtu = 1450 },
      ]
      initialization = {
        datastore_id = "local-lvm"
        interface    = "ide2"
        ipv4         = { address = "10.0.0.100/24", gateway = "10.0.0.1" }
        user_account = { username = "nverk", keys = local.default_ssh_keys }
      }
      operating_system = { type = "l26" }
    }

    k3s_server_02 = {
      import_id     = "poseidon/101"
      node_name     = "poseidon"
      vm_id         = 101
      name          = "k3s-server-02"
      tags          = ["k3s-server"]
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
        { interface = "scsi1", datastore_id = "local-lvm", size = 100, discard = "on", iothread = true, ssd = true },
      ]
      network_devices = [
        { bridge = "vxvnet1", mac_address = "BC:24:11:62:2E:10", model = "virtio", mtu = 1450 },
      ]
      initialization = {
        datastore_id = "local-lvm"
        interface    = "ide2"
        ipv4         = { address = "10.0.0.101/24", gateway = "10.0.0.1" }
        user_account = { username = "nverk", keys = local.default_ssh_keys }
      }
      operating_system = { type = "l26" }
    }

    k3s_agent_02 = {
      import_id     = "hera/106"
      node_name     = "hera"
      vm_id         = 106
      name          = "k3s-agent-02"
      tags          = ["k3s-a"]
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
        { interface = "scsi1", datastore_id = "local-lvm", size = 100, discard = "on", iothread = true, ssd = true },
      ]
      network_devices = [
        { bridge = "vxvnet1", firewall = true, mac_address = "BC:24:11:7F:E0:90", model = "virtio", mtu = 1450 },
      ]
      initialization = {
        datastore_id = "local-lvm"
        interface    = "ide2"
        ipv4         = { address = "10.0.0.104/24", gateway = "10.0.0.1" }
        user_account = { username = "nverk", keys = local.default_ssh_keys }
      }
      operating_system = { type = "l26" }
    }
  }
}
