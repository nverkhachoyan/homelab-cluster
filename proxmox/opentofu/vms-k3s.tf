locals {
  k3s_vms = {
    k3s_server_01 = {
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
        user_account = { username = "nverk", keys = local.default_ssh_keys_with_comment }
      }
      operating_system = { type = "l26" }
    }
  }
}
