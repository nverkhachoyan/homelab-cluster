resource "proxmox_virtual_environment_vm" "vms" {
  for_each = local.vms

  name      = each.value.name
  node_name = each.value.node_name
  vm_id     = each.value.vm_id
  tags      = try(each.value.tags, [])
  template  = try(each.value.template, false)
  on_boot   = try(each.value.on_boot, false)
  started   = try(each.value.started, null)

  delete_unreferenced_disks_on_destroy = try(each.value.delete_unreferenced_disks_on_destroy, null)
  protection                           = try(each.value.protection, null)
  purge_on_destroy                     = try(each.value.purge_on_destroy, null)
  stop_on_destroy                      = try(each.value.stop_on_destroy, null)

  bios          = try(each.value.bios, "seabios")
  machine       = try(each.value.machine, null)
  scsi_hardware = try(each.value.scsi_hardware, "virtio-scsi-single")
  boot_order    = try(each.value.boot_order, null)

  dynamic "agent" {
    for_each = try(each.value.agent, null) == null ? [] : [each.value.agent]

    content {
      enabled = try(agent.value.enabled, true)
      timeout = try(agent.value.timeout, null)
      trim    = try(agent.value.trim, null)
      type    = try(agent.value.type, null)

      dynamic "wait_for_ip" {
        for_each = try(agent.value.wait_for_ip, null) == null ? [] : [agent.value.wait_for_ip]

        content {
          disabled = try(wait_for_ip.value.disabled, null)
          ipv4     = try(wait_for_ip.value.ipv4, null)
          ipv6     = try(wait_for_ip.value.ipv6, null)
        }
      }
    }
  }

  cpu {
    cores   = each.value.cpu.cores
    sockets = try(each.value.cpu.sockets, 1)
    type    = try(each.value.cpu.type, "x86-64-v2-AES")
  }

  memory {
    dedicated = each.value.memory.dedicated
  }

  dynamic "efi_disk" {
    for_each = try(each.value.efi_disk, null) == null ? [] : [each.value.efi_disk]

    content {
      datastore_id      = try(efi_disk.value.datastore_id, "local-lvm")
      file_format       = try(efi_disk.value.file_format, null)
      pre_enrolled_keys = try(efi_disk.value.pre_enrolled_keys, null)
      type              = try(efi_disk.value.type, "4m")
    }
  }

  dynamic "disk" {
    for_each = each.value.disks

    content {
      datastore_id = try(disk.value.datastore_id, "local-lvm")
      discard      = try(disk.value.discard, null)
      interface    = disk.value.interface
      iothread     = try(disk.value.iothread, null)
      size         = try(disk.value.size, null)
      ssd          = try(disk.value.ssd, null)
    }
  }

  network_device = [
    for device in try(each.value.network_devices, []) : {
      bridge       = device.bridge
      disconnected = try(device.disconnected, null)
      enabled      = try(device.enabled, null)
      firewall     = try(device.firewall, null)
      mac_address  = try(device.mac_address, null)
      model        = try(device.model, "virtio")
      mtu          = try(device.mtu, null)
      queues       = try(device.queues, null)
      rate_limit   = try(device.rate_limit, null)
      trunks       = try(device.trunks, null)
      vlan_id      = try(device.vlan_id, null)
    }
  ]

  dynamic "initialization" {
    for_each = try(each.value.initialization, null) == null ? [] : [each.value.initialization]

    content {
      datastore_id         = try(initialization.value.datastore_id, "local-lvm")
      file_format          = try(initialization.value.file_format, null)
      interface            = try(initialization.value.interface, "ide2")
      meta_data_file_id    = try(initialization.value.meta_data_file_id, null)
      network_data_file_id = try(initialization.value.network_data_file_id, null)
      type                 = try(initialization.value.type, null)
      upgrade              = try(initialization.value.upgrade, null)
      user_data_file_id    = try(initialization.value.user_data_file_id, null)
      vendor_data_file_id  = try(initialization.value.vendor_data_file_id, null)

      dynamic "dns" {
        for_each = try(initialization.value.dns, null) == null ? [] : [initialization.value.dns]

        content {
          domain  = try(dns.value.domain, null)
          servers = try(dns.value.servers, null)
        }
      }

      dynamic "ip_config" {
        for_each = try(initialization.value.ipv4, null) == null && try(initialization.value.ipv6, null) == null ? [] : [initialization.value]

        content {
          dynamic "ipv4" {
            for_each = try(ip_config.value.ipv4, null) == null ? [] : [ip_config.value.ipv4]

            content {
              address = ipv4.value.address
              gateway = try(ipv4.value.gateway, null)
            }
          }

          dynamic "ipv6" {
            for_each = try(ip_config.value.ipv6, null) == null ? [] : [ip_config.value.ipv6]

            content {
              address = ipv6.value.address
              gateway = try(ipv6.value.gateway, null)
            }
          }
        }
      }

      dynamic "user_account" {
        for_each = try(initialization.value.user_account, null) == null ? [] : [initialization.value.user_account]

        content {
          username = user_account.value.username
          keys     = try(user_account.value.keys, [])
        }
      }
    }
  }

  dynamic "operating_system" {
    for_each = try(each.value.operating_system, null) == null ? [] : [each.value.operating_system]

    content {
      type = try(operating_system.value.type, null)
    }
  }

  dynamic "serial_device" {
    for_each = try(each.value.serial_devices, [])

    content {
      device = try(serial_device.value.device, null)
    }
  }

  dynamic "vga" {
    for_each = try(each.value.vga, null) == null ? [] : [each.value.vga]

    content {
      clipboard = try(vga.value.clipboard, null)
      memory    = try(vga.value.memory, null)
      type      = try(vga.value.type, null)
    }
  }

  lifecycle {
    ignore_changes = [
      reboot,
      started,
      initialization[0].user_account[0].password,
    ]
  }
}
