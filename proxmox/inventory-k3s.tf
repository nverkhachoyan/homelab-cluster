locals {
  k3s_vms = {
    k3s_server_01 = {
      node_name  = "zeus"
      vm_id      = 100
      name       = "k3s-server-01"
      tags       = ["k3s-server"]
      on_boot    = true
      bios       = "ovmf"
      machine    = "q35"
      boot_order = ["scsi0"]
      agent      = { enabled = true }
      cpu        = { cores = 4, sockets = 1, type = "x86-64-v2-AES" }
      memory     = { dedicated = 16384 }
      efi_disk   = { pre_enrolled_keys = true }
      disks = [
        { interface = "scsi0", size = 32, discard = "on", iothread = true, ssd = true },
        { interface = "scsi1", size = 100, discard = "on", iothread = true, ssd = true },
      ]
      network_devices = [
        { bridge = proxmox_sdn_vnet.internal_lan.id, mac_address = "BC:24:11:BD:43:33", model = "virtio", mtu = 1450 },
      ]
      initialization = {
        dns          = { domain = "alligator-rainbow.ts.net", servers = ["1.1.1.1", "1.0.0.1"] }
        ipv4         = { address = "10.0.0.100/24", gateway = "10.0.0.1" }
        user_account = { username = "nverk", keys = local.default_ssh_keys_with_comment }
      }
      operating_system = { type = "l26" }
    }
  }
}
