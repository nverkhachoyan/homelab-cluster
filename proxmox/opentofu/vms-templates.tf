locals {
  template_vms = {
    ubuntu_cloudinit_template = {
      import_id     = "zeus/1000"
      node_name     = "zeus"
      vm_id         = 1000
      name          = "ubuntu-cloudinit"
      template      = true
      bios          = "ovmf"
      machine       = "q35"
      scsi_hardware = "virtio-scsi-single"
      boot_order    = ["scsi0"]
      agent         = { enabled = true }
      cpu           = { cores = 1, sockets = 1, type = "x86-64-v2-AES" }
      memory        = { dedicated = 1024 }
      efi_disk      = { datastore_id = "local-lvm", type = "4m", pre_enrolled_keys = true }
      disks = [
        { interface = "scsi0", datastore_id = "local-lvm", size = 32, discard = "on", iothread = true, ssd = true },
      ]
      network_devices = [
        { bridge = "vmbr0", firewall = true, mac_address = "BC:24:11:7D:2E:A5", model = "virtio" },
      ]
      initialization = {
        datastore_id = "local-lvm"
        interface    = "ide2"
        ipv4         = { address = "dhcp" }
        user_account = { username = "nverk", keys = local.default_ssh_keys }
      }
      operating_system = { type = "l26" }
    }

    actions_runner_template = {
      import_id     = "hera/113"
      node_name     = "hera"
      vm_id         = 113
      name          = "actions-runner-template"
      template      = true
      on_boot       = true
      bios          = "ovmf"
      machine       = "q35"
      scsi_hardware = "virtio-scsi-single"
      boot_order    = ["scsi0"]
      agent         = { enabled = true }
      cpu           = { cores = 2, sockets = 1, type = "x86-64-v2-AES" }
      memory        = { dedicated = 4096 }
      efi_disk      = { datastore_id = "local-lvm", type = "4m", pre_enrolled_keys = true }
      disks = [
        { interface = "scsi0", datastore_id = "local-lvm", size = 32, discard = "on", iothread = true, ssd = true },
      ]
      network_devices = [
        { bridge = "vmbr0", firewall = true, mac_address = "BC:24:11:71:37:DC", model = "virtio" },
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

    ubuntu_runner_template = {
      import_id     = "athena/9000"
      node_name     = "athena"
      vm_id         = 9000
      name          = "ubuntu-runner-template"
      template      = true
      on_boot       = true
      bios          = "ovmf"
      machine       = "q35"
      scsi_hardware = "virtio-scsi-single"
      agent         = { enabled = true, trim = true }
      cpu           = { cores = 4, sockets = 1, type = "qemu64" }
      memory        = { dedicated = 8192 }
      efi_disk      = { datastore_id = "local-lvm", type = "4m" }
      disks = [
        { interface = "scsi0", datastore_id = "local-lvm", discard = "on", iothread = true },
      ]
      network_devices = [
        { bridge = "vmbr0", mac_address = "BC:24:11:3A:5D:47", model = "virtio" },
      ]
      initialization = {
        datastore_id      = "local-lvm"
        interface         = "ide2"
        user_data_file_id = "local:snippets/gh-runner-template.yaml"
        ipv4              = { address = "dhcp" }
        ipv6              = { address = "dhcp" }
        user_account = {
          username = "casadmin"
          keys     = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBoVotkT+jNCRAtiZM+tQSh/grcNL17yldLsy1OhnsSb"]
        }
      }
      operating_system = { type = "l26" }
      serial_devices   = [{ device = "socket" }]
      vga              = { type = "serial0" }
    }
  }
}
